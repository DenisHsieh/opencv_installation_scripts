function run () {
    # step 1. install brew (http://brew.sh)
    brew tap homebrew/science
    brew install eigen tbb hdf5 tesseract \
        libjpeg-turbo libtiff libpng pyenv-virtualenv

    # step 2. install pyenv
    env PYTHON_CONFIGURE_OPTS="--enable-shared" CFLAGS="-O2" pyenv install 3.6.0
    pyenv global 3.6.0

    # step 2.1. choose your default shell
    echo -n "Which one is your default shell?/n1.bash\n2.zsh\nPlease type 1 or 2 >"
    read shell_type
    if [ $shell_type == 1 ]; then
        # bash
        echo -e "\nif which pyenv > /dev/null; then eval \"\$(pyenv init -)\"; fi" >> ~/.bash_profile
        source ~/.bash_profile
        install_numpy
        build_opencv
    elif [ $shell_type == 2 ]; then
        # zsh
        echo -e "\nif which pyenv > /dev/null; then eval \"\$(pyenv init -)\"; fi" >> ~/.zshrc
        source ~/.zshrc
        install_numpy
        build_opencv
    else
        echo -e "\nI don\'t understand!"
    fi
}

function install_numpy () {
    # step 3. install numpy
    pip install -U pip setuptools wheel cython numpy
}

function build_opencv () {
    # step 4. build opencv
    sudo mkdir -p /opt/src
    sudo chown $(whoami):staff /opt
    sudo chown $(whoami):staff /opt/src
    cd /opt/src
    curl -L https://github.com/opencv/opencv/archive/3.2.0.zip -o opencv32.zip
    curl -L https://github.com/opencv/opencv_contrib/archive/3.2.0.zip -o opencv32contrib.zip
    unzip opencv32.zip
    unzip opencv32contrib.zip
    mv -v opencv-3.2.0 /opt/src/opencv32_py36
    mv -v opencv_contrib-3.2.0 /opt/src/opencv32_py36_contrib
    cd /opt/src/opencv32_py36
    mkdir /opt/src/opencv32_py36/release
    cd /opt/src/opencv32_py36/release
    cmake \
        -D CMAKE_INSTALL_PREFIX=/opt/opencv32_py36 \
        -D OPENCV_EXTRA_MODULES_PATH=/opt/src/opencv32_py36_contrib/modules \
        -D BUILD_opencv_python2=OFF \
        -D BUILD_opencv_python3=ON \
        -D BUILD_TIFF=ON \
        -D BUILD_opencv_java=OFF \
        -D WITH_CUDA=OFF \
        -D ENABLE_AVX=ON \
        -D WITH_OPENGL=ON \
        -D WITH_OPENCL=ON \
        -D WITH_IPP=OFF \
        -D WITH_TBB=ON \
        -D WITH_EIGEN=ON \
        -D WITH_V4L=OFF \
        -D WITH_VTK=OFF \
        -D BUILD_TESTS=OFF \
        -D BUILD_PERF_TESTS=OFF \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D PYTHON3_LIBRARY=$(python -c "import re, os.path; print(os.path.normpath(os.path.join(os.path.dirname(re.__file__), '..', 'libpython3.6m.dylib')))") \
        -D PYTHON3_EXECUTABLE=$(which python) \
        -D PYTHON3_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
        -D PYTHON3_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") ..
        make -j8
        make install
        # Installing: /Users/adamgradzki/.pyenv/versions/3.6.0/lib/python3.6/site-packages/cv2.cpython-36m-darwin.so
        
        pyenv virtualenv 3.6.0 main
        pyenv global main
        pip install -U pip setuptools wheel numpy
        ln -s "$HOME/.pyenv/versions/3.6.0/lib/python3.6/site-packages/cv2.cpython-36m-darwin.so" \
            "$HOME/.pyenv/versions/main/lib/python3.6/site-packages/cv2.cpython-36m-darwin.so"
}

run