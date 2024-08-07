import sys, getopt

print( "Arguments must be in this order: snoreport, snoscan, cmsearch" )

def IntersecOfSets(arr1, arr2, arr3):
    # Converting the arrays into sets
    s1 = set(arr1)
    s2 = set(arr2)
    s3 = set(arr3)
      
    # Calculates intersection of 
    # sets on s1 and s2
    set1 = s1.intersection(s2)         #[80, 20, 100]
      
    # Calculates intersection of sets
    # on set1 and s3
    result_set = set1.intersection(s3)
      
    # Converts resulting set to list
    final_list = list(result_set)
    return final_list

def UniqueElements(a,b,c):
        set_a = set(a)
        set_b = set(b)
        set_c = set(c)

        only_in_a = set_a - set_b - set_c
        only_in_b = set_b - set_a - set_c
        only_in_c = set_c - set_a - set_b

        return only_in_a, only_in_b, only_in_c

file1 = sys.argv[1]
file2 = sys.argv[2]
file3 = sys.argv[3]
is_ens = sys.argv[4]

freport = open (str(file1))
fscan = open (str(file2))
frfam = open (str(file3))

report = []
scan = []
rfam = []
if is_ens == "ensid":
    for line in freport:
        if (line.startswith(">")):
            line = line[1:19]
            #print(line)
            report.append(line)
    for line in fscan:
        if (line.startswith(">>")):
            line = line[3:21]
            #print(line)
            scan.append(line)
    for line in frfam:
            line = line[0:18]
            #print(line)
            rfam.append(line)
else:
    for line in freport:
        if (line.startswith(">")):
                line=line.split(" ")
                line=line[0].split(":")
                report.append(line[0][1:])
    for linescan in fscan:
        if (linescan.startswith(">>")):
                linescan=linescan.split(":")
                linescan=linescan[0].split(" ")
                scan.append(linescan[1])
    for linefam in frfam:
                linefam=linefam.split(";")
                linefam=linefam[0].split(':')
                rfam.append(linefam[0])



final_list = IntersecOfSets(report,rfam,scan)
print(final_list, len(final_list))
only_report, only_rfam, only_scan = UniqueElements(report,rfam,scan)
print("only-scan", len(only_scan), "only-report", len(only_report), "only-cmsearch", len(only_rfam))
scanreport = set ([e for e in scan if e in report]) - set(final_list)
scanrfam = set ([e for e in scan if e in rfam]) - set(final_list)
rfamreport = set ([e for e in rfam if e in report]) - set(final_list)
print ("scanreport", len(scanreport), "scancmsearch", len(scanrfam), "cmsearchreport", len(rfamreport))
print (len(list(set(scan))), len(list(set(report))), len(list(set(rfam))))

freport.close()
fscan.close()