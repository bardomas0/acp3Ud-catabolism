import os
import shutil
import raw_to_csv


path_raw = "C:/Users/bardo/Files/Uni/Praktika/microplate reader/raw"
path_csv = "C:/Users/bardo/Files/Uni/Praktika/microplate reader/csv"

enable_labeling = input("Label wells Y/N? ")

if enable_labeling == "Y" or enable_labeling == "y":
    enable_labeling = True
else:
    enable_labeling = False

for year in os.listdir(path_raw):
    # Direktorijose ieško visų metų folderių

    if not os.path.exists(os.path.join(path_csv, year)):
        # Jei neranda metų folderio, sukuria jį
        os.mkdir(os.path.join(path_csv, year))
    date = os.path.join(path_raw, year)

    for date in os.listdir(date):
        if not os.path.exists(os.path.join(path_csv, year, date)):
            # Jei neranda datos folderio, sukuria jį
            os.mkdir(os.path.join(path_csv, year, date))
        # Metų direktorijose ieško datų folderių

        experiment = os.path.join(path_raw, year, date)

        for experiment_name in os.listdir(experiment):
            # Datų direktorijose ieško specifinių .txt dokumentų

            if experiment_name.find(".txt") > -1 and experiment_name.find("legend.txt") == -1:
                # Jeigu dokumento pavadinime yra ".txt", tęsia

                txt_path = os.path.join(path_raw, year, date, experiment_name)
                destination = os.path.join(path_csv, year, date)

                csv_path = txt_path[:-4] + "_short.csv"
                print(csv_path)

                if not os.path.exists(csv_path):
                    # Jei neranda folderio, tik tada perverčia iš txt į csv

                    raw_to_csv.raw_to_csv_short(txt_path, destination, enable_labeling)
                    # idk kodėl jis deda viską tiesiai į raw folderį, bet kolkas tai veikia and I am not complaining

                if not os.path.exists(os.path.join(destination, experiment_name[-4] + "_short.csv")):
                    # Jei neranda nukopijuoto csv tenais kur reikia, nukopijuoja

                    shutil.copy(csv_path, destination)

                    # Kolkas negali patikrint ar naujas failas naujesnis už seną
