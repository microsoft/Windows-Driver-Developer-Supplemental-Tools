import pandas as pd

# Specify the path to your Excel file
excel_file_path_263 = 'results2024-01-12-21-04-00-901107.xlsx'
excel_file_path_2154 = 'results2024-01-12-01-30-27-169974_codeql2.15.4.xlsx'
# Read the Excel file into a dataframe
df_old_ver = pd.read_excel(excel_file_path_263, index_col=0)
df_new_ver = pd.read_excel(excel_file_path_2154, index_col=0)


# Delete rows from df_old_ver that are not present in df_new_ver
differences = pd.DataFrame()
for row in df_old_ver.index:
    if row not in df_new_ver.index:
        print(row, 'not in new version <--------------------------------------------------------------------')
        differences['df_old_ver'] = df_old_ver.loc[row]
        df_old_ver = df_old_ver.drop(row)

for row in df_new_ver.index:
    if row not in df_old_ver.index:
        print(row, 'not in old version')
        differences['df_new_ver'] = df_new_ver.loc[row]
        df_new_ver = df_new_ver.drop(row)

df_new_ver = df_new_ver.sort_index()
df_old_ver = df_old_ver.sort_index()    


for i in df_new_ver.columns:
    if i not in df_old_ver.columns:
        print(i + ' not in old version')
        differences['df_new_ver'] = df_new_ver[i]
        df_new_ver = df_new_ver.drop(i, axis=1)
for i in df_old_ver.columns:
    if i not in df_new_ver.columns:
        print(i + ' not in new version <--------------------------------------------------------------------')
        differences['df_old_ver'] = df_old_ver[i]
        df_old_ver = df_old_ver.drop(i, axis=1)
# Compare the two dataframes
df_diff = df_old_ver.compare(df_new_ver, keep_equal=True)


# Print the differences
print(differences)
print(df_diff)
df_diff.to_excel('df_diff.xlsx')
# Write df_old_ver to Excel
df_old_ver.to_excel('df_old_ver.xlsx')

# Write df_new_ver to Excel
df_new_ver.to_excel('df_new_ver.xlsx')
