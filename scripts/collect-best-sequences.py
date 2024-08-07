import csv
import itertools
# get lists by running the merge-sno-res-CD.py and merge-sno-res-HACA.py 
sequence_ids_HACA = ['1754', '6278', '1021', '5985', '6247', '1027', '2168', '1865', '333', '6484', '1020', '6248', '194', '312', '1255', '5983', '749', '1441', '1173', '6482', '6521', '1756', '1846', '1017', '1870', '1107', '1015', '7060', '2226', '1879', '6675', '1024', '6481', '1245', '6390', '1248', '1292', '1786', '774', '6529']
sequence_ids_CD = ['5999', '7060', '2133', '1052', '1220', '1035', '6451', '2130', '154', '7191', '6292', '6260', '131', '2132', '130', '367', '5974', '546', '6564', '1236', '7137', '7139', '132', '6447', '1237', '1884', '6714', '1224']
ids = list(set(sequence_ids_CD + sequence_ids_HACA))
# print (len(ids))
active_sequence_name = ""
fasta = {}
with open("./our-plus-time-set-bowtie2/candidates_timeandtissue.fasta") as file_one:
    for line in file_one:
        line = line.strip()
        if not line:
            continue
        if line.startswith(">"):
            active_sequence_name = line.split(':')[0][1:]
            if active_sequence_name not in fasta:
                fasta[active_sequence_name] = []
            continue
        sequence = line
        fasta[active_sequence_name].append(sequence)


fout = "common3.fasta"
fo = open(fout, "w")
for k, v in fasta.items():
    if k in ids:
        fo.write('>' + str(k) + '\n' + str(v)[2:-2] + '\n')
fo.close()

data = []
for i in ids:
    with open('./our-plus-time-set-bowtie2/candidates_timeandtissue.fasta', 'r') as f:
        for i in f:
            if i.startswith(">"):
                location = i.split(':')
                end = location[3].split('-')[1]
                data.append([
                    'chr' + location[2],
                    int(location[3].split('-')[0]),
                    int(end.split('(')[0]),
                    location[0][1:],
                    0,
                    location[-1][-3]
                ]
                )
data.sort()
data = list(data for data, _ in itertools.groupby(data))

with open('new' + '.bed', "w", newline="") as fout:
    writer = csv.writer(fout, delimiter='\t')
    for line in data:
        if line[3] in ids:
            writer.writerow(line)
