#Documentation
#Assignment4


Plan and Logging of Work:
We used the planner app for organizing our work. Jannat took the lead by assigning tasks and setting due dates for each team member. Despite her efforts, we had several challenges along the way. We used to frequently fall behind schedule and also missed personal deadlines, which added stress to the project. However, the planner app proved to be a useful tool in keeping everyone on the same page. It allowed us to stay updated on the progress of each task and to maintain a clear understanding on how everything is going. This level of transparency and coordination among the team helped to stay on the track of completing the project on time.
We have attached the screenshot to the github under planner folder.



Ekamjot
Setting up Github repo for the Assignment
Working on the movement of the arm.
Importing robo arm.
Setting the camera.
Set up of Animations.
Adding of InGame-Goals
Detection of Goals using Area3D
Invalidating unlawful goals (going in and out of goal) to earn score.
Labels to show instructions
Adding Area3D to change color when ball in range.
Labels to show game stats
The Goal Text and sound
Rain particles and sound
Debugging
Helped with Documentation

Gunpreet


Set the World Environment
Camera configuration: Rotation, field view using keys (Later dropped)
Setup of secondary objects in game world
General polishing of the complete project
Using Path3d to make the goals move.
Getting the dynamic goal path to loop.
Designed Soccer Goals (later dropped)
Setting different materials for objects
Adding label for controls
Compiling everything

Jannat

Working on landscape (hilly terrain) [Pushed to a separate branch; later dropped]
Managing commits
Completing the readme file.
Create the plan on planner app.
Arrange team meetings.
Adding texture to plane.

Lucas
Making sure the ball was following physics.
Tried using BoneAttachment to grab the ball. (Dropped)
Worked on arm picking up the ball.
implemented detection of objects using raycast3d

Anurag
Working on applying the throw and grab animations to do their work.
Added Jump for RobotArm
Worked with RayCast3d to get the grab animation working.
adding throwing mechanics, movement and camera rotation (avoids over-rotation).
@export for easy tweaking of movement, gravity, and object control parameters.



Demonstrate adaptations of previous assignment techniques.
Jannat: Landscape, Texture
Ekam: Particle systems
Gunpreet: Path3D
Anurag: Physics Implementation
Lucas: Physics Implementation


Animation Camera and Controls from DEVLOGLOGAN’s Video.


We set up the project following DevLogLogan's video tutorial. Starting with importing the robot arm and replacing the node type with Character3D to follow better. Implemented the initial script, which included configuring WASD controls for movement and setting up idle animations to enhance the character's responsiveness. While the camera control setup provided in the video was great, we couldn't get it to work as good and did not meet expectations. After some adjustments and troubleshooting. We managed to refine the camera system to achieve smoother and more intuitive control. Other animations were added too.


#References:
Campbell, R. (2024). RobotArm.blend [File]. COMP360, University of the Fraser Valley. Retrieved from https://myclass.ufv.ca/bbcswebdav/pid-3129125-dt-content-rid-43725423_1/xid-43725423_1
Mr.T.T. (2023, February 2). Goal sound effect [Sound]. Freesound. Retrieved from https://freesound.org/people/Mr.T.T/sounds/672603/
QubodupDev. (2020). Hilly terrain in Godot [Video]. YouTube. Retrieved from https://www.youtube.com/watch?v=k_ISq6JyVSs
Savva, D., & Zaal, G. (2022). Orlando Stadium [3D asset]. Poly Haven. Retrieved December 13, 2024, from https://polyhaven.com/a/orlando_stadium (License: CC0 1.0 universal)
Speakwithanimals. (2020). Rain Slowly Passing [Sound]. Freesound. Retrieved from https://freesound.org/people/speakwithanimals/sounds/525046/ (License: CC0 1.0 universal)
Watt Interactive. (2023). Easy particle rain in Godot 4 [Video]. YouTube. Retrieved from https://www.youtube.com/watch?v=dLWM8jxQx-4&t=445s

