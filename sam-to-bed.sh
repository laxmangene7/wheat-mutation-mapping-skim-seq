# sam to bed/txt file with overlapping bins
#!/bin/bash -l
#SBATCH --job-name=samstotxt1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=00-02:00:00   # DD-HH:MM:SS
#SBATCH --mem-per-cpu=10G    # Memory per core
#SBATCH --output="%x_%j.out"
#SBATCH --error="%x_%j.err"

# ==============================================================================
# Script Name: sam_to_overlapping_bins.sh
# Description: Processes SAM files from skim-seq/WGS data to calculate read counts
#              within 100 Kb non-overlapping and 50 Kb overlapping sliding windows.
#              Outputs filtered, sorted, and unique bin coordinates with midpoints.
# Author: adhikal
# ==============================================================================

# Define input directory path
DIR="/ibex/project/c2141/Wheat_Wild_Wheat_Managed-by_LA/Jagger/2NS/joboutput-NEX8081/NEX0080/all_fastqs/trimmed/all_sam"

# Loop through all SAM files in the current working directory
for sample in *.sam; do
    # Extract baseline name without extension
    base=$(basename "$sample" ".sam")
    echo "Processing sample: ${base}..."

    # --------------------------------------------------------------------------
    # 1. Generate Standard 100 Kb Bins
    # --------------------------------------------------------------------------
    # Filter reads: skip headers, keep properly paired (YT:Z:CP), uniquely mapped (NH:i:1)
    # Extract Chr and Pos, round down positions to nearest 100Kb window, count occurrences
    awk '!/^@/ && /YT:Z:CP/ && /NH:i:1/ { print $3 "\t" int($4 / 100000) * 100000 }' "${DIR}/${base}.sam" | \
        sort -k1,1 -k2,2n | \
        uniq -c > "${base}.tmp_100Kb.bin.txt"

    # Format 100 Kb intervals (Chr, Start, End, Count)
    awk '{gsub(/ +/, "\t"); OFS="\t"; print $2, $3, $3 + 100000, $1}' "${base}.tmp_100Kb.bin.txt" | \
        sed 's/^[ \t]*//;s/[ \t]*$//' > "${base}.tmp_100Kb.bin_range.txt"

    # --------------------------------------------------------------------------
    # 2. Generate Overlapping 50 Kb Bins (Offset Windows)
    # --------------------------------------------------------------------------
    # Shift coordinate tracking window forward by 50 Kb to generate the overlapping set
    awk '!/^@/ && /YT:Z:CP/ && /NH:i:1/ { print $3 "\t" (int(($4 + 50000) / 100000) * 100000 + 50000) }' "${DIR}/${base}.sam" | \
        sort -k1,1 -k2,2n | \
        uniq -c > "${base}.tmp_50Kb.bin.txt"

    # Format 50 Kb offset intervals with explicit start-end ranges
    awk 'BEGIN { prev = 0; curr = 0; } 
    {
        if ($2 != prev) { curr = 0; }
        # Structure fields safely: Count, Chromosome, Position offset
        print $2 "\t" $3 "\t" ($3 - 50000) "\t" ($3 + 50000) "\t" $1;
        prev = $2;
        curr = $3;
    }' "${base}.tmp_50Kb.bin.txt" | awk '{print $1 "\t" $3 "\t" $4 "\t" $5}' > "${base}.tmp_50Kb.bin_range.txt"

    # --------------------------------------------------------------------------
    # 3. Merge, Clean, and Calculate Midpoints
    # --------------------------------------------------------------------------
    # Combine standard and overlapping bins
    cat "${base}.tmp_50Kb.bin_range.txt" "${base}.tmp_100Kb.bin_range.txt" > "${base}.tmp_merged.txt"

    # Sort lexicographically by chromosome and numerically by start/end boundaries
    sort -k1,1V -k2,2n -k3,3n "${base}.tmp_merged.txt" > "${base}.tmp_merged.ordered.txt"

    # Remove duplicates based on window positions (Crucial for ultra-low coverage / skim-seq)
    awk '!seen[$1,$2,$3]++' "${base}.tmp_merged.ordered.txt" > "${base}.tmp_merged.nodups.txt"

    # Append the calculated center point (Mean position) of each bin window
    awk 'OFS="\t" { print $1, $2, $3, $4, ($2 + $3) / 2 }' "${base}.tmp_merged.nodups.txt" \
        > "${base}.final_merged_added.bin.range.ordered.remove.dup.added.mean.bin.txt"

    # --------------------------------------------------------------------------
    # 4. Clean Up Per-Sample Intermediary Workfiles
    # --------------------------------------------------------------------------
    rm "${base}.tmp_"*

done

echo "Workflow completed successfully!"
