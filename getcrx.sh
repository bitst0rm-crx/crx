#!/usr/bin/env bash
# A bash script to download chrome extension files from Chrome Web Store
# 30.01.2019, https://github.com/bitst0rm

declare -a arr=(
"https://chrome.google.com/webstore/detail/chrome-extension-source-v/jifpbeccnghkjeaalbbjmodiffmgedin"
"https://chrome.google.com/webstore/detail/ecleaner-forget-button/ejhlpopncnfaaeicmbdnddebccnkfenn"
"https://chrome.google.com/webstore/detail/enhancer-for-youtube/ponfpcnoihfmfllpaingbgckeeldkhle"
"https://chrome.google.com/webstore/detail/exif-viewer/nafpfdcmppffipmhcpkbplhkoiekndck"
"https://chrome.google.com/webstore/detail/gismeteo/bfegaehidkkcfaikpaijcdahnpikhobf"
"https://chrome.google.com/webstore/detail/google-dictionary-by-goog/mgijmajocgfcbeboacabfgobmjgjcoja"
"https://chrome.google.com/webstore/detail/google-docs-offline/ghbmnnjooekpmoecnnnilnnbdlolhkhi"
"https://chrome.google.com/webstore/detail/imagus/immpkjjlgappgfkkfieppnmlhakdmaab"
"https://chrome.google.com/webstore/detail/javascript-and-css-code-b/iiglodndmmefofehaibmaignglbpdald"
"https://chrome.google.com/webstore/detail/json-formatter/mhimpmpmffogbmmkmajibklelopddmjf"
"https://chrome.google.com/webstore/detail/loady-video-and-music-dow/afkpfjljjhhonjehpkmgonimjjgaheap"
"https://chrome.google.com/webstore/detail/magnifying-glass/elhdjgjjmodgmhkokebhegekjooiaofm"
"https://chrome.google.com/webstore/detail/markdown-preview-plus/febilkbfcbhebfnokafefeacimjdckgl"
"https://chrome.google.com/webstore/detail/nimbus-screenshot-screen/bpconcjcammlapcogcnnelfmaeghhagj"
"https://chrome.google.com/webstore/detail/office-editing-for-docs-s/gbkeegbaiigmenfmjfclcdgdpimamgkj"
"https://chrome.google.com/webstore/detail/pixelblock/jmpmfcjnflbcoidlgapblgpgbilinlem"
"https://chrome.google.com/webstore/detail/scroll-to-top-button/chinfkfmaefdlchhempbfgbdagheknoj"
"https://chrome.google.com/webstore/detail/search-by-image-by-google/dajedkncpodkggklbegccjpmnglmnflm"
"https://chrome.google.com/webstore/detail/showpassword/bbiclfnbhommljbjcoelobnnnibemabl"
"https://chrome.google.com/webstore/detail/skip-redirect/jaoafjdoijdconemdmodhbfpianehlon"
"https://chrome.google.com/webstore/detail/storage-area-explorer/ocfjjjjhkpapocigimmppepjgfdecjkb"
"https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo"
"https://chrome.google.com/webstore/detail/tineye-reverse-image-sear/haebnnbpedcbhciplfhjjkbafijpncjl"
"https://chrome.google.com/webstore/detail/ublock-origin-extra/pgdnlhfefecpicbbihgmbmffkjpaplco"
"https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm"
"https://chrome.google.com/webstore/detail/url-incrementer/hjgllnccfndbjbedlecgdedlikohgbko"
"https://chrome.google.com/webstore/detail/url-switcher/jhokdbpcimdpkmgbdnmgcbklohaeleel"
"https://chrome.google.com/webstore/detail/video-downloadhelper/lmjnegcaeklhafolokijcfjliaokphfk"
"https://chrome.google.com/webstore/detail/video-styler-brightness-a/bfmgdnjlifbmedglimhnbhgkefanaiep"
"https://chrome.google.com/webstore/detail/view-image-info-propertie/jldjjifbpipdmligefcogandjojpdagn"
"https://chrome.google.com/webstore/detail/view-image/jpcmhcelnjdmblfmjabdeclccemkghjk"
"https://chrome.google.com/webstore/detail/viewhance/impppjchnpfgknmbaaghfeopcgfoilac"
"https://chrome.google.com/webstore/detail/volume-controller/cnlmgnlnpjaniibglhnppikopdcclfjp"
"https://chrome.google.com/webstore/detail/whenx-organize-your-googl/dgafcidlgmbcehokgdeghmfnbpbfhihh"
)

# Pretty print
print () {
    if [ "$2" == "error" ] ; then
        COLOR="7;91m" # light red
    elif [ "$2" == "success" ] ; then
        COLOR="7;92m" # light green
    elif [ "$2" == "warning" ] ; then
        COLOR="7;33m" # yellow
    elif [ "$2" == "info" ] ; then
        COLOR="7;94m" # light blue
    else
        COLOR="0m" # colorless
    fi

    STARTCOLOR="\\e[$COLOR"
    ENDCOLOR="\\e[0m"

    printf "$STARTCOLOR%b$ENDCOLOR" "$1\\n"
}

case "$(uname -s)" in
    Linux*)     os=linux;;
    Darwin*)    os=mac;;
    *)          os=win;;
esac

case "$(uname -m)" in
    armv*)      arch=arm
                os_arch=arm
                nacl_arch=arm;;
    *64)        arch=x64
                os_arch=x86_64
                nacl_arch=x86-64;;
    *)          arch=x32
                os_arch=x86_32
                nacl_arch=x86-32;;
esac

c=0
for i in "${arr[@]}"
do
    # Check if it's a valid Chrome Web Store URL
    if [[ "$i" =~ ^https?://chrome\.google\.com/webstore/detail/ ]]; then
        # Check if the given URL exists
        if curl -sfI "$i" -o /dev/null; then
            ((c++))
            # Parse the extension ID of the given URL
            id=${i##*/}
            id=${id%\?*}
            # Parse the name of the extension from Chrome Web Store
            name=$(curl -s "$i" | sed -n 's/.*<meta property="og:title" content="\([^"]*\).*/\1/p')
            # Parse the version of the extension from HTTP headers
            # Tip: Use "chrome://net-internals/" to sniff the download url
            url='https://clients2.google.com/service/update2/crx?response=redirect'
            url+="&os=${os}"
            url+="&arch=${arch}"
            url+="&os_arch=${os_arch}"
            url+="&nacl_arch=${nacl_arch}"
            url+="&prod=chromecrx"
            url+="&prodchannel="
            url+="&prodversion=70.0.3538.77"
            url+="&lang=de"
            url+="&acceptformat=crx2,crx3"
            url+="&x=id%3D${id}%26installsource%3Dondemand%26uc"
            version=$(curl -sIL "$url" | sed -n 's/location:*//p' | sed -e 's/.*extension_\(.*\).crx/\1/')
            # Clean up filename
            file=$(echo "${name}_${version}.crx" | tr -s ' ' '-' | tr -d '\r\n' | sed -e 's/&amp;/\&/g' -e 's/[\/:*?"<>|]/_/g')
            # Download the extension file with corrected filename
            print "[${c}] Downloading ${file} ..." "success"
            curl -L "${url}" -o "${file}"
        else
            print "[WARNING] URL does not exist: $i" "warning"
        fi
    else
        print "[WARNING] invalid URL: $i" "warning"
    fi
    print "\n"
done
