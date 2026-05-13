# See PyCharm help at https://www.jetbrains.com/help/pycharm/

# Tikslas – iš duomenų failo viską perdaryt į tvarkingą csv
# Iš šito:
"""
350
Kinetic read 1 (0:00:06)
	1	2	3	4	5	6	7	8	9	10	11	12
A													350 Read#1
B													350 Read#1
C													350 Read#1
D													350 Read#1
E													350 Read#1
F	1.823												350 Read#1
G	1.680	1.652	1.694	1.726	1.779								350 Read#1
H	1.737	1.718	1.759	1.662	2.020								350 Read#1

ir t.t.
"""

# Į csv su
"""
Laikas s, Šulinėlio eilutė, Šulinėlio stulpelis, Sugerties vertė, Read numeris, Bangos ilgis
"""
import csv
import os

def raw_to_csv(file_name, destination, labeling = False):

    # RAW FAILO NUSKAITYMAS Į ATSKIRUS READ'US

    single_read = [] # Skirtas vienam laiko momentui read'as
    all_reads = [] # Visų read'ų sąrašas

    with open(file_name, "r") as f:

        counter = 0

        for l in f:
            single_read.append(l)
            counter += 1

            if counter > 11:
                # Vienas read'as duoda 11 eilučių duomenų
                # Nuskaitęs 11 eilučių, juos sumeta į visų read'ų sąrašą
                all_reads.append(single_read)
                counter = 0

                single_read = []



    # INDIVIDUALAUS READ'O DUOMENŲ SURAŠYMAS

    # Stulpelių pavadinimai
    if labeling:
        data = [
            ["Time s", "Well", "Label", "Absorption", "Read number", "Wavelength"]
        ]
    else:
        data = [
            ["Time s", "Well", "Absorption", "Read number", "Wavelength"]
        ]

    #
    well = ""
    absorption = 0
    label_dict = {}

    for read_row in all_reads:

        # Bangos ilgio vertė
        wavelength = float(read_row[0])

        # Read'o skaičiaus vertė
        row_split = read_row[1].split(" ")
        read_number = int(row_split[2])

        # Laiko vertė
        time = row_split[3][1:-2].split(":")
        time_raw = int(time[0])*3600 + int(time[1])*60 + int(time[2])

        # Kiekvieno individualaus šulinėlio vertės
        row = 3
        while row < 11:
            row_split = read_row[row].split("\t") # Perskaito šulinėlio raidę ir atskiria į naują list pagal tab'us
            row_split = row_split[:-1] # Nuima perteklinę šulinėlio raidę ir read'o informaciją iš list'o

            for column in row_split[1:]:

                if column: # Patikrina ar skaitomame šulinėlyje yra skaičius

                    # Jei šulinėlyje yra skaičius, prideda koks tai šulinėlis ir jo absorpcijos vertę
                    absorption = column
                    well_index = row_split[1:].index(column) + 1 # Šulinėlio koordinačių skaičiaus dalis

                    # Dėl skaitymo ir vėlesnio tvarkymo efektyvumo padaro, kad koordinačių skaičius prasidėtų "0", jeigu jis mažesnis už 10
                    if well_index < 10:
                        well_index = "0" + str(well_index)
                    else:
                        well_index = str(well_index)

                    well = row_split[0] + well_index

                    if labeling:
                        # Jeigu reikia, paprašo userio pavadinti šulinėlius
                        if label_dict.get(well) == None:
                            file_name_split = file_name.split("/")[-1].split("\\")
                            readable_file_name = file_name_split[-1]
                            label = input("Name well: " + well + " from file: " + readable_file_name + " (" + file_name_split[-2][:5] + ") ")
                            #label = label.encode('utf-8')

                            label_dict.update({well: label})

                        new_data_row = [time_raw, well, label_dict.get(well), absorption, read_number, wavelength]
                        data.append(new_data_row)

                    else:
                        # Bei visą tai įrašo pakartotinai į list
                        new_data_row = [time_raw, well, absorption, read_number, wavelength]
                        data.append(new_data_row)

            row += 1



    # ĮRAŠYMAS Į CSV

    csv_name = file_name[:-4]

    with open(os.path.join(destination, csv_name + ".csv"), "w", newline='') as f:
        writer = csv.writer(f)
        writer.writerows(data)

    return 0



def raw_to_csv_short(file_name, destination, labeling=False):
    # RAW FAILO NUSKAITYMAS Į ATSKIRUS READ'US

    single_read = []  # Skirtas vienam laiko momentui read'as
    all_reads = []  # Visų read'ų sąrašas

    with open(file_name, "r") as f:

        counter = 0

        for l in f:
            single_read.append(l)
            counter += 1

            if counter > 11:
                # Vienas read'as duoda 11 eilučių duomenų
                # Nuskaitęs 11 eilučių, juos sumeta į visų read'ų sąrašą
                all_reads.append(single_read)
                counter = 0

                single_read = []

    if labeling:

        legend = file_name.split("/")[-1].split("\\")
        legend.pop(-1)

        legend_path = "C:/Users/bardo/Files/Uni/Praktika/microplate reader"

        for i in legend:
            legend_path = legend_path + "/" + i

        legend_path = legend_path + "/" + "legend.txt"

        label_dict = {}

        try:
            with open(legend_path, "r") as f:
                for line in f:
                    label = line.split(" : ")

                    label_dict.update({label[0] : label[1]})
                    print(label_dict)
        except:
            print(legend_path + " not found")


    # INDIVIDUALAUS READ'O DUOMENŲ SURAŠYMAS

    # Stulpelių pavadinimai
    data = [
        ["Read number", "Time s"]
    ]

    well = ""
    absorption = 0
    wells_appended = False

    for read_row in all_reads:

        # Bangos ilgio vertė
        wavelength = float(read_row[0])

        # Read'o skaičiaus vertė
        row_split = read_row[1].split(" ")
        read_number = int(row_split[2])

        # Laiko vertė
        time = row_split[3][1:-2].split(":")
        time_raw = int(time[0]) * 3600 + int(time[1]) * 60 + int(time[2])

        new_data_row = [read_number, time_raw]

        # Kiekvieno individualaus šulinėlio vertės
        row = 3
        while row < 11:
            row_split = read_row[row].split("\t")  # Perskaito šulinėlio raidę ir atskiria į naują list pagal tab'us
            row_split = row_split[:-1]  # Nuima perteklinę šulinėlio raidę ir read'o informaciją iš list'o

            for column in row_split[1:]:

                if column:  # Patikrina ar skaitomame šulinėlyje yra skaičius

                    # Jei šulinėlyje yra skaičius, prideda koks tai šulinėlis ir jo absorpcijos vertę
                    absorption = column
                    well_index = row_split[1:].index(column) + 1  # Šulinėlio koordinačių skaičiaus dalis

                    # Dėl skaitymo ir vėlesnio tvarkymo efektyvumo padaro, kad koordinačių skaičius prasidėtų "0", jeigu jis mažesnis už 10
                    if well_index < 10:
                        well_index = "0" + str(well_index)
                    else:
                        well_index = str(well_index)

                    well = row_split[0] + well_index

                    new_data_row.append(absorption)

                    print(new_data_row)

                    print(well)

                    if not wells_appended:
                        if labeling:
                            data[0].append(label_dict.get(well))
                        else:
                            data[0].append(well)



            row += 1

        data.append(new_data_row)
        print(data[0])

        wells_appended = True

    # ĮRAŠYMAS Į CSV

    csv_name = file_name[:-4]

    with open(os.path.join(destination, csv_name + "_short.csv"), "w", newline='') as f:
        writer = csv.writer(f)
        writer.writerows(data)

    return 0