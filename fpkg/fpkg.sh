#!/bin/bash

MIRROR_DIR="C:/Users/edink/OneDrive/fpkg/repository-sites"

# Function to display usage information
display_usage() {
    echo "Usage: $0 {install|remove|list} package_name"
    echo "  install <package_name>  Install the specified package."
    echo "  remove <package_name>   Remove the specified package."
    echo "  list                    List available packages."
}

# Function to parse XML and extract values
function parse_xml() {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

# Function to install package
install_package() {
    PACKAGE_NAME=$1
    PACKAGE_VERSION=$2
    PACKAGE_URL=$3
    INSTALL_PATH=$4

    echo "Installing $PACKAGE_NAME version $PACKAGE_VERSION..."
    wget $PACKAGE_URL -O /tmp/$PACKAGE_NAME.tar.gz
    mkdir -p $INSTALL_PATH
    tar -xzf /tmp/$PACKAGE_NAME.tar.gz -C $INSTALL_PATH
    echo "$PACKAGE_NAME installed at $INSTALL_PATH."
}

# Function to remove package
remove_package() {
    PACKAGE_NAME=$1
    rm -rf /usr/local/$PACKAGE_NAME
    echo "$PACKAGE_NAME removed."
}

# Function to list available packages from all mirrors
list_packages() {
    echo "Checking for repository mirrors in $MIRROR_DIR"
    
    if [[ ! -d $MIRROR_DIR ]]; then
        echo "Error: $MIRROR_DIR directory not found!"
        exit 1
    fi

    echo "Available packages:"
    for MIRROR in "$MIRROR_DIR"/*; do
        if [[ -d $MIRROR ]]; then
            XML_FILE="$MIRROR/repo.xml"
            if [[ -f $XML_FILE ]]; then
                echo "Reading packages from $XML_FILE"
                while IFS= read -r line; do
                    echo "$line"
                done < $XML_FILE
                echo "Finished reading $XML_FILE"
            else
                echo "No repo.xml found in $MIRROR"
            fi
        else
            echo "$MIRROR is not a directory"
        fi
    done
    echo "Finished listing packages."
}

# Main script logic
if [[ $# -eq 0 ]]; then
    display_usage
    exit 1
fi

echo "Command: $1"
if [[ $2 ]]; then
    echo "Package: $2"
fi

case $1 in
    install)
        if [[ -z $2 ]]; then
            echo "Error: No package name provided."
            display_usage
            exit 1
        fi
        PACKAGE_NAME=$2
        for MIRROR in "$MIRROR_DIR"/*; do
            if [[ -d $MIRROR ]]; then
                XML_FILE="$MIRROR/repo.xml"
                if [[ -f $XML_FILE ]]; then
                    while parse_xml; do
                        echo "Entity: $ENTITY, Content: $CONTENT"
                        if [[ $ENTITY == "name" && $CONTENT == $PACKAGE_NAME ]]; then
                            INSTALL_PACKAGE=true
                        elif [[ $INSTALL_PACKAGE == true && $ENTITY == "version" ]]; then
                            PACKAGE_VERSION=$CONTENT
                        elif [[ $INSTALL_PACKAGE == true && $ENTITY == "url" ]]; then
                            PACKAGE_URL=$CONTENT
                        elif [[ $INSTALL_PACKAGE == true && $ENTITY == "installPath" ]]; then
                            INSTALL_PATH=$CONTENT
                            install_package $PACKAGE_NAME $PACKAGE_VERSION $PACKAGE_URL $INSTALL_PATH
                            INSTALL_PACKAGE=false
                        fi
                    done < $XML_FILE
                else
                    echo "No repo.xml found in $MIRROR"
                fi
            else
                echo "$MIRROR is not a directory"
            fi
        done
        ;;
    remove)
        if [[ -z $2 ]]; then
            echo "Error: No package name provided."
            display_usage
            exit 1
        fi
        remove_package $2
        ;;
    list)
        list_packages
        ;;
    *)
        echo "Error: Invalid command."
        display_usage
        exit 1
        ;;
esac
