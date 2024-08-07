import sys


print("Arguments must be in this order: snoreport, snoGPS, cmsearch")


def IntersecOfSets(arr1, arr2, arr3):
    # Converting the arrays into sets
    s1 = set(arr1)
    s2 = set(arr2)
    s3 = set(arr3)
    
    # Calculates intersection of 
    # sets on s1 and s2
    set1 = s1.intersection(s2)    
    # [80, 20, 100]
    
    # Calculates intersection of sets
    # on set1 and s3
    result_set = set1.intersection(s3)
    
    # Converts resulting set to list
    final_list = list(result_set)
    return final_list


def UniqueElements(a, b, c):
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

freport = open(str(file1))
fgps = open(str(file2))
frfam = open(str(file3))

report = []
gps = []
rfam = []
if is_ens == "ensid":
    for line in freport:
        if(line.startswith(">")):
            line = line[1:19]
            report.append(line)
    for line in fgps:
        if(line.startswith(">")):
            line = line[1:19]
            gps.append(line)
    for line in frfam:
        line = line[0:18]
        rfam.append(line)

else:
    for line in freport:
        if(line.startswith(">")):
            line = line.split(" ")
            line = line[0].split(":")
            report.append(line[0][1:])

    for linegps in fgps:
        if(linegps.startswith(">")):
            linegps = linegps.split("\t")
            linegps = linegps[0].split(":")
            gps.append(linegps[0][1:])

    for linefam in frfam:
        linefam = linefam.split(";")
        linefam = linefam[0].split(':')
        rfam.append(linefam[0])

final_list = IntersecOfSets(report, rfam, gps)
print(final_list,  len(final_list))
only_report, only_rfam, only_gps = UniqueElements(report, rfam, gps)
print(len(only_gps), len(only_report), len(only_rfam))
gpsreport = set([e for e in gps if e in report]) - set(final_list)
gpsrfam = set([e for e in gps if e in rfam]) - set(final_list)
rfamreport = set([e for e in rfam if e in report]) - set(final_list)
print("gpsreport", len(gpsreport), "gpscmsearch", len(gpsrfam), "cmsearchreport", len(rfamreport))
print(len(list(set(gps))), len(list(set(report))), len(list(set(rfam))))

freport.close()
fgps.close()