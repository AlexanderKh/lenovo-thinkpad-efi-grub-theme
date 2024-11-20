#! /usr/bin/env bash

if [[ $# -ne 2 ]]
then
  echo "Incorrect number of arguments"
  echo ""
  echo "Usage: ./build.sh <scaling> <mode>"
  echo "Example: ./build.sh 1 l"
  echo ""
  echo "<scaling> values supported:"
  echo "   1   - for display with ~750 lines (hd)"
  echo "   1.5 - for display with ~1100 lines (full-hd)"
  echo "   2   - for display with 1500+ lines (hi-res)"
  echo ""
  echo "<mode> values supported:"
  echo "   l   - light mode (faithful)"
  echo "   d   - dark mode"
  exit 1
fi

scaling=$1
mode=$2

THEME_NAME="Lenovo Thinkpad EFI"
THEME_COMPLIANT_NAME="lenovo-thinkpad-efi"

case $mode in
  "l")
    MODE_TEXT="light"
    LENOVO_BLUE="#1f8ee7"
    LENOVO_PURPLE="#7f629c"
    PROGRESS_GRAY="#BBBBBB"
    SEPARATOR_GRAY="#A4A4A4"
    BACKGROUND="#FFFFFF"
    TEXT_COLOR="#000000"
    ;;

  "d")
    MODE_TEXT="dark"
    LENOVO_BLUE="#398ecd"
    LENOVO_PURPLE="#9667cc"
    PROGRESS_GRAY="#ababab"
    SEPARATOR_GRAY="#A4A4A4"
    BACKGROUND="#1c1c21"
    TEXT_COLOR="#FFFFFF"
    ;;

  *)
    echo "mode should be l or d"
    exit 1
    ;;
esac

case $scaling in
  "1")
    MAIN_FONT_SIZE=18
    HEADER_FONT_SIZE=32
    PROGRESS_FONT_SIZE=16
    TERMINAL_FONT_SIZE=16
    ITEM_SIZE=38
    ITEM_BORDER_SIZE=2
    BOTTOM_LINE_SIZE=3
    PROGRESS_BAR_SIZE_HALF=14
    PADDING=30
    LOGO_SIZE=60
    MENU_WIDTH_HALF=300
    MENU_HEIGHT_HALF=200
    ;;

  "1.5")
    MAIN_FONT_SIZE=22
    HEADER_FONT_SIZE=42
    PROGRESS_FONT_SIZE=20
    TERMINAL_FONT_SIZE=20
    ITEM_SIZE=48
    ITEM_BORDER_SIZE=2
    BOTTOM_LINE_SIZE=4
    PROGRESS_BAR_SIZE_HALF=20
    PADDING=40
    LOGO_SIZE=85
    MENU_WIDTH_HALF=400
    MENU_HEIGHT_HALF=300
    ;;

  "2")
    MAIN_FONT_SIZE=30
    HEADER_FONT_SIZE=52
    PROGRESS_FONT_SIZE=28
    TERMINAL_FONT_SIZE=26
    ITEM_SIZE=64
    ITEM_BORDER_SIZE=3
    BOTTOM_LINE_SIZE=5
    PROGRESS_BAR_SIZE_HALF=25
    PADDING=50
    LOGO_SIZE=120
    MENU_WIDTH_HALF=500
    MENU_HEIGHT_HALF=400
    ;;

  *)
    echo "scaling should be 1 or 2"
    exit 1
    ;;
esac

BOTTOM_LABELS_POS_OFFSET=$(($MAIN_FONT_SIZE + $BOTTOM_LINE_SIZE + $PADDING))
BOTTOM_LINE_POS_OFFSET=$(($PADDING + $BOTTOM_LABELS_POS_OFFSET))
MENU_WIDTH=$(($MENU_WIDTH_HALF * 2))
MENU_HEIGHT=$(($MENU_HEIGHT_HALF * 2))
PROGRESS_BAR_SIZE=$(($PROGRESS_BAR_SIZE_HALF * 2))
HEADER_OFFSET_MIN=$(($PADDING + $LOGO_SIZE))

theme_dir_name="$THEME_NAME"\ "$scaling"x-"$MODE_TEXT"
build_dir=./build/"$theme_dir_name"
theme_dir=$build_dir/$THEME_COMPLIANT_NAME
icons_dir=$theme_dir/icons

mkdir -p "$build_dir"
mkdir -p "$theme_dir"
mkdir -p "$icons_dir"

# Make main font
grub-mkfont -s "$MAIN_FONT_SIZE" -o "$theme_dir/roboto-$MAIN_FONT_SIZE.pf2" "./src/fonts/roboto/Roboto-Medium.ttf"
# Make font for header
grub-mkfont -s "$HEADER_FONT_SIZE" -o "$theme_dir/roboto-$HEADER_FONT_SIZE.pf2" "./src/fonts/roboto/Roboto-Light.ttf"
# Make font for progress bar
grub-mkfont -s "$PROGRESS_FONT_SIZE" -o "$theme_dir/roboto-$PROGRESS_FONT_SIZE.pf2" "./src/fonts/roboto/Roboto-Regular.ttf"
# Make terminal font
grub-mkfont -s "$TERMINAL_FONT_SIZE" -o "$theme_dir/terminus-ttf-$TERMINAL_FONT_SIZE.pf2" "./src/fonts/terminus-ttf/TerminusTTF.ttf"

# Pictures
svgexport "./src/logos/thinkpad_logo_"$mode".svg" "$theme_dir/thinkpad_logo.png" :"$LOGO_SIZE"
svgexport "./src/logos/lenovo_logo_"$mode".svg" "$theme_dir/lenovo_logo.png" :"$LOGO_SIZE"

LENOVO_LOGO_WIDTH="$(identify -format '%[fx:w]' "$theme_dir/lenovo_logo.png")"
LENOVO_LOGO_OFFSET=$(($LENOVO_LOGO_WIDTH + $PADDING))

convert -size 1x1 xc:"$BACKGROUND" PNG32:"$theme_dir/background.png"
convert -size 1x1 xc:"$LENOVO_BLUE" PNG32:"$theme_dir/progress_active_c.png"
convert -size 1x1 xc:"$PROGRESS_GRAY" PNG32:"$theme_dir/progress_inactive_c.png"
convert -size 1x1 xc:"$SEPARATOR_GRAY" PNG32:"$theme_dir/separator.png"
convert -size "$ITEM_BORDER_SIZE"x1 xc:transparent PNG32:"$theme_dir/menu_inactive_e.png"
convert -size "$ITEM_BORDER_SIZE"x1 xc:transparent PNG32:"$theme_dir/menu_inactive_w.png"
convert -size 1x"$ITEM_BORDER_SIZE" xc:transparent PNG32:"$theme_dir/menu_inactive_n.png"
convert -size 1x"$ITEM_BORDER_SIZE" xc:transparent PNG32:"$theme_dir/menu_inactive_s.png"
convert -size "$ITEM_BORDER_SIZE"x"$ITEM_BORDER_SIZE" xc:transparent PNG32:"$theme_dir/menu_inactive_ne.png"
convert -size "$ITEM_BORDER_SIZE"x"$ITEM_BORDER_SIZE" xc:transparent PNG32:"$theme_dir/menu_inactive_se.png"
convert -size "$ITEM_BORDER_SIZE"x"$ITEM_BORDER_SIZE" xc:transparent PNG32:"$theme_dir/menu_inactive_sw.png"
convert -size "$ITEM_BORDER_SIZE"x"$ITEM_BORDER_SIZE" xc:transparent PNG32:"$theme_dir/menu_inactive_nw.png"
convert -size "$ITEM_BORDER_SIZE"x1 xc:"$LENOVO_BLUE" PNG32:"$theme_dir/menu_selected_e.png"
convert -size "$ITEM_BORDER_SIZE"x1 xc:"$LENOVO_BLUE" PNG32:"$theme_dir/menu_selected_w.png"
convert -size 1x"$ITEM_BORDER_SIZE" xc:"$LENOVO_BLUE" PNG32:"$theme_dir/menu_selected_n.png"
convert -size 1x"$ITEM_BORDER_SIZE" xc:"$LENOVO_BLUE" PNG32:"$theme_dir/menu_selected_s.png"
convert -size "$ITEM_BORDER_SIZE"x"$ITEM_BORDER_SIZE" xc:"$LENOVO_BLUE" PNG32:"$theme_dir/menu_selected_ne.png"
convert -size "$ITEM_BORDER_SIZE"x"$ITEM_BORDER_SIZE" xc:"$LENOVO_BLUE" PNG32:"$theme_dir/menu_selected_se.png"
convert -size "$ITEM_BORDER_SIZE"x"$ITEM_BORDER_SIZE" xc:"$LENOVO_BLUE" PNG32:"$theme_dir/menu_selected_sw.png"
convert -size "$ITEM_BORDER_SIZE"x"$ITEM_BORDER_SIZE" xc:"$LENOVO_BLUE" PNG32:"$theme_dir/menu_selected_nw.png"

for filename in ./src/icons/*.svg; do
  name_ext=${filename##*/}
  name=${name_ext%.*}
  svgexport "$filename" "$icons_dir/$name.png" "$ITEM_SIZE":"$ITEM_SIZE"
done

# Compile theme.txt template
export MAIN_FONT_SIZE HEADER_FONT_SIZE PROGRESS_FONT_SIZE TERMINAL_FONT_SIZE
export HEADER_OFFSET_MIN BOTTOM_LABELS_POS_OFFSET BOTTOM_LINE_POS_OFFSET
export BOTTOM_LINE_SIZE PADDING ITEM_SIZE LENOVO_LOGO_OFFSET
export PROGRESS_BAR_SIZE PROGRESS_BAR_SIZE_HALF
export MENU_WIDTH MENU_HEIGHT MENU_WIDTH_HALF MENU_HEIGHT_HALF
export LENOVO_BLUE TEXT_COLOR LENOVO_PURPLE
cat ./src/theme.txt.tmpl | envsubst > "$theme_dir/theme.txt"

cp "./LICENSE.txt" "$build_dir/LICENSE.txt"
cp "./THIRD_PARTY_ASSETS.txt" "$build_dir/THIRD_PARTY_ASSETS.txt"
cp "./src/install.sh" "$build_dir/install.sh"

# ZIP for distribution
cd build
if [[ -f "$theme_dir_name".zip ]]
then
  rm "$theme_dir_name".zip
fi
zip -rq "$theme_dir_name".zip "$theme_dir_name"
