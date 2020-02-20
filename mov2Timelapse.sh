#!/bin/bash
set -u;



#==================================================
# Mov to Timelapse 1.0.0
# > Author: Genbu Hase
# > Framework: FFmpeg
#==================================================



#### Constants ####
TEMP_DIRNAME="temp";


#### Variables ####
mov_path="NULL";
timelapse_path="NULL";
mov_fps=60;
timelapse_fps=10;
timelapse_playrate=5;

compile_mode="NULL"
is_confirmed="NULL";


#### Initialization ####
trap "[ -d ./${TEMP_DIRNAME} ] && rm -r ./${TEMP_DIRNAME}" 0;


#### Requests to input variables ####
read -p "元動画のファイルパス > " mov_path; ([ -z $mov_path ] || [ ! -f ./$mov_path ]) && exit 1;
read -p "タイムラプス動画のファイルパス > " timelapse_path; [ -z $timelapse_path ] && exit 1;

read -p "元動画のFPS (初期値: 60) > " mov_fps;
expr ${mov_fps:="NULL"} + 1 > /dev/null 2>&1; ([ $? -gt 0 ] || [ $mov_fps -le 0 ]) && mov_fps=60;

read -p "タイムラプス動画のFPS (初期値: 10) > " timelapse_fps;
expr ${timelapse_fps:="NULL"} + 1 > /dev/null 2>&1; ([ $? -gt 0 ] || [ $timelapse_fps -le 0 ]) && timelapse_fps=10;

read -p "タイムラプス動画の再生速度(n倍速) (初期値: 5) > " timelapse_playrate; [ ${timelapse_playrate:=5} -le 0 ] && timelapse_playrate=5;

echo "動画の生成方法を選択してください ('q' で終了)";
select item in "Basic" "Advanced"; do
	if [[ $REPLY =~ [Qq] ]]; then
		exit 0;
	fi
	
	case $item in
		"Basic" ) ;;
		"Advanced" ) ;;
		* ) continue ;;
	esac
	
	compile_mode=$item;
	break;
done

read -p "生成しますか？(y/n) > " is_confirmed; [[ $is_confirmed =~ [Nn] ]] && exit 0;
mkdir $TEMP_DIRNAME;

case $compile_mode in
	"Basic" )
		# Generates a timelapse with a provided speed
		ffmpeg -r $mov_fps -i $mov_path -an -filter:v "setpts=PTS/$timelapse_playrate" -filter:a "asetpts=PTS/$timelapse_playrate" $TEMP_DIRNAME/${TEMP_DIRNAME}.mp4;
		# Changes fps of timelapse
		ffmpeg -y -i $TEMP_DIRNAME/${TEMP_DIRNAME}.mp4 -r $timelapse_fps $timelapse_path; ;;
	"Advanced" )
		# Gets thumbnails
		ffmpeg -r $mov_fps -i $mov_path -r 1 $TEMP_DIRNAME/${TEMP_DIRNAME}%03d.jpg;
		# Combines thumbnails into a timelapse
		ffmpeg -y -r $timelapse_playrate -i $TEMP_DIRNAME/${TEMP_DIRNAME}%03d.jpg -r $timelapse_fps -vcodec libx264 $timelapse_path; ;;
esac

echo "タイムラプス動画が正常に生成されました";
read -p "何かキーを押してください……";