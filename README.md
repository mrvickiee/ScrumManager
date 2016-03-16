# ScrumManager
A management system to help teams implement scrum in their projects

## Getting Started
1. Create a new directory named **ScrumMaster**
2. Open terminal and **cd ScrumMaster**
3. **git clone https://github.com/PerfectlySoft/Perfect.git**
4. **git clone https://github.com/mrvickiee/ScrumManager.git**
5. Open Xcode and go File -> New -> Workspace. Name it 'ScrumMaster.xcworkspace'
6. In your Xcode workspace,  right click to open the context menu in Project Navigator, 	select Add files to “ScrumMaster”, make sure **Copy items into destination group's folder** is unchecked for the following
  1. Navigate to the **Perfect/PerfectServer** directory, select **PerfectServer.xcodeproj** and add
  2. Navigate to the **Perfect/PerfectLib** directory, select **PerfectLib.xcodeproj** and add
  3. Navigate to the **Perfect/Connectors/MongoDB** directory, select **MongoDB.xcodeproj** and add
  4. Navigate to the **ScrumMaster** directory, select **ScrumMaster.xcodeproj** and add
7. Change the active scheme in the toolbar to ‘ScrumMaster’. If there is no ScrumMaster scheme available, select ‘New Scheme..’ and click add
8. Click on the schema and select 'Edit Schema'
9. Change the executable to '**PerfectServer HTTP.app**' and check the **shared** checkbox
10. Make sure to start Mongo with the ‘mongod’ command in terminal and select run in Xcode

