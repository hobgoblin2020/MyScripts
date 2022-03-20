import os

fileList = (os.path.join(root, filename)
            # PATH TO FILES unc IF ON SERVER
            for root, _, filenames in os.walk(r'\\SERVER\SHARE\PATH\TO\FOLDER')
            for filename in filenames
            )

for file in fileList:
    newname = file.replace('_', ' ')
    if newname != file:
        os.rename(file, newname)
