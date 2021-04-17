#!/bin/bash

categories_list=""
categories_parent_list=""
categories_child_list=""
desktop='Desktop Entry'
search_key="Categories"
appplication_folder="/usr/share/applications/"
sed_regx=""
reset_folder=true

get_app_category()
{
	regex="^\["
	regexparentfolder="[0-9][0-9]-[a-z].*"
	regexchildfolder="[0-9][0-9]-[0-9][0-9]-[a-z].*"
	section=$(echo "$1" | tr ' ' '_')
	found=false

	if [ -f "$file" ]
	then
		while IFS='=' read -r key value
		do
			# If blank line present continue
			[ -z "$key" ] && continue			
			
			key=$(echo $key | tr ' ' '_')
			res=`expr match $key $regex`
			
			[ $found = false ] && [ $key != "[$section]" ] &&  continue
		  	[ $found = true ] && [ $res = 1 ] && break
		  
		 	found=true
			if [ "$key" = "$3" ] && [ $res = 0 ];
			then
				key=$(echo $key | tr '.' '_')
				eval ${key}=\${value}
			fi
		done < "$2"
		
		catlist=$(echo ${Categories} | tr ";" "\n")
		
		for ct in $catlist
		do
			# Check if category already present in category list
			present=false
			for iter in $categories_parent_list
			do
				if [ $iter = $ct ];
				then
					present=true
					break
				fi
			done
			
			[ $present = true ] && break
			
			parexpr=`expr match $ct $regexparentfolder`
			
			if [ $parexpr != 0 ];
			then
				ct_par_list=$(echo "$categories_parent_list\n$ct")
				categories_parent_list=$ct_par_list
			fi
			
			present=false
			for iter in $categories_child_list
			do
				if [ $iter = $ct ];
				then
					present=true
					break
				fi
			done
			
			[ $present = true ] && break
			
			childexpr=`expr match $ct $regexchildfolder`
			
			if [ $childexpr != 0 ];
			then
				ct_child_list=$(echo "$categories_child_list\n$ct")
				categories_child_list=$ct_child_list
			fi
			categories_list=$ct_list
		done
	else
		echo "$file not found."
	fi
}

print_list()
{
	for categ in $1
	do
		readablename=$(echo $categ | tr '-' ' ')s
		folder=$( echo ${readablename} | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1' )
		echo " Category : " $categ "Folder : " $folder 
	done
}

reset_gnome_folders()
{
	gsettings reset org.gnome.desktop.app-folders folder-children
	reset_folder=true
}

create_gnome_folder_menu()
{
	for categ in $1
	do
		readablename=$(echo $categ | tr '-' ' ')
		foldername=$( echo ${readablename} | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1' )
		foldername=$(echo "$foldername" | sed -e "$sed_regx" )

		old_folders=$(gsettings get org.gnome.desktop.app-folders folder-children)
		old_list=$(echo ${old_folders} | tr "[" " " | tr "]" " ")
		fld_path=$(echo "/org/gnome/desktop/app-folders/folders/$categ/")
		name=$(echo "'$categ'")
		
		if [ $reset_folder = true ];
		then
			gsettings set org.gnome.desktop.app-folders folder-children "[$name]"
			reset_folder=false
		else
			gsettings set org.gnome.desktop.app-folders folder-children "[$old_list, $name]"
		fi
		
		(gsettings set org.gnome.desktop.app-folders.folder:$fld_path name "$foldername") && echo "Creating folder:" $foldername
		(gsettings set org.gnome.desktop.app-folders.folder:$fld_path categories "[$name]") && echo "Applications of category" $name "Added Successfully...\n"
	done
}

cd $appplication_folder

echo "Fetching application list..."
for file in *
do
	get_app_category "$desktop" "$file" "$search_key"
done

echo "Setting up Menu..."
sleep 1

sed_regx="s/^[0-9][0-9] [0-9][0-9]//"
create_gnome_folder_menu "$categories_child_list"
sed_regx="s/^[0-9][0-9]//"
create_gnome_folder_menu "$categories_parent_list"

# Sort Application Menus
gsettings reset org.gnome.shell app-picker-layout
echo "Process Complete... You may have to re-login for changes to reflect."
