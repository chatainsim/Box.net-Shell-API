get_ticket() {
  TICKET=`curl -3 -s "https://www.box.com/api/1.0/rest?action=get_ticket&api_key=$API" | awk -F "<ticket>" {'print $2'} | awk -F "</ticket>" {'print $1'}`
}
display_auth_url() {
  echo "Please open this URL to authorize the application :"
  echo "https://www.box.com/api/1.0/auth/"$TICKET | sed 's/ //g'
  read test
}
get_token() {
  URL_TOKEN=`echo "https://www.box.com/api/1.0/rest?action=get_auth_token&api_key=$API&ticket="$TICKET | sed 's/ //g'`
  TOKEN=`curl -3 -s "$URL_TOKEN" | awk -F "<auth_token>" {'print $2'} | awk -F "</auth_token>" {'print $1'}`
#  echo $TOKEN > token.log
}
update_conf() {
  echo "API="\"$API\" > config.sh
  echo "TOKEN="\"$TOKEN\" | sed 's/ //g' >> config.sh
}
get_list() {
  curl -3 https://www.box.com/api/2.0/folders/$folder_id \
  -H "Authorization: BoxAuth api_key=$API&auth_token=$TOKEN"
}
upload() {
  if [ -f "$filename" ];
  then
     curl -3 https://upload.box.com/api/2.0/files/content \
     -H "Authorization: BoxAuth api_key=$API&auth_token=$TOKEN" \
     -F filename=@"$filename" \
     -F folder_id=$folder_id
  else
     echo -e "\nError, file specified does not exist.\n"
  fi
}
new_folder() {
  curl -3 https://api.box.com/2.0/folders/0 \
  -H "Authorization: BoxAuth api_key=$API&auth_token=$TOKEN" \
  -d '{"name":"New Folder"}' \
  -X POST
}
remove() {
     curl -3 https://upload.box.com/api/2.0/files/$file_id \
     -H "Authorization: BoxAuth api_key=$API&auth_token=$TOKEN" \
     -X DELETE
}
check_api() {
if [ "$API" == "" ];
then
        echo ""
	echo "-------------------------------------------------------------------------"
        echo "You should add you api key in the config.sh file."
        echo "To get an API key go here : https://www.box.com/developers/services/edit/"
	echo "-------------------------------------------------------------------------"
        echo ""
        exit 1
fi
}
usage() {
echo -e "\nHelp :\n-h | --help\n\nAuthentification to box.net :\n-a | --auth				Authentification apps with your box.net account."
echo -e "     --force				Use --force to force the re-authentification even if you already have done before."
echo -e "\nUpload a file to box.net :\n-u | --upload				For uploading a file, use the -f parameter to specified the filename."
echo -e "-f | --file				Use -f followed by filename (eg. : box.sh -f filename).\n-d | directory				Specified a directory to upload the file to. Use the folder ID."
echo -e "\nList files and folders :\n-l | --list				List the contents of a folder. Default is root folder (ID=0).\n					Specified a folder ID with -d (eg. box.sh -l -d FOLDER_ID)."
echo -e "\nOther options :\n-s | --silent				Do not display output other than the json return from box.net\n"
}
