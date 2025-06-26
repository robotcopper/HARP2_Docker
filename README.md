# HARP2_Docker

This repository wraps the [HARP2\_ROS](https://github.com/robotcopper/HARP2_ROS) project inside a Docker environment, providing a standalone ROS 2 Humble workspace with Gazebo 11.
It serves as a frozen snapshot of the work done on the HARP2 robot, before transitioning to the next-generation HARP3.


## 📁 Project Structure

```
HARP2_Docker/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── setup.sh
├── LICENSE
├── README.md
└── ros2_ws/
    └── src/
        └── HARP2_ROS/
```


## ✅ Requirements

* [git-lfs](https://git-lfs.com/)
* [Docker](https://docs.docker.com/engine/install/ubuntu/)
* [Visual Studio Code](https://code.visualstudio.com/)

  * With the [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension


## ⚙️ Installation

Clone the repository with submodules:

```bash
git clone --recurse-submodules git@github.com:robotcopper/HARP2_Docker.git
```

Then, open the `HARP2_Docker` folder in VS Code and run:

> `Dev Containers: Reopen in Container`
> (from the Command Palette: `F1` or `Ctrl+Shift+P`)

The Docker container will be built automatically, and everything will be set up.
You’ll be ready to work with the HARP2 robot out of the box.


## 🚀 Usage

Refer to the [HARP2\_ROS](https://github.com/robotcopper/HARP2_ROS) documentation for full details.
To quickly start the simulation, you can launch:

```bash
ros2 launch robot_bringup robot_nav_bringup.launch.py use_TopicBasedSystem_hardware_interface:=False
```

## 📄 License

This project is licensed under the [BSD 3-Clause License](LICENSE).
