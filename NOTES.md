# Notes

-- monitor res: 7x5 per block

## COmmands

```
GTMO:

./CraftOS-PC_console.exe --id 0 --label "World Admin Server" --directory ./computers/ --mount /src=./dev/ --script ./scripts/TankMonitor.lua


CNVD:
./CraftOS-PC_console.exe --id 1 --label "Cernavoda" --directory ./computers/ --mount /src=./dev/ --script ./scripts/Cernavoda.lua

NTWK:
./CraftOS-PC_console.exe --id 3 --label "Networking" --directory ./computers/ --mount /src=./dev/ --script ./scripts/Networking.lua
```

peripheral.find("modem", rednet.open); rednet.host("demo","A"); print("waiting…"); local s,m=rednet.receive("demo"); print(("from %d: %s"):format(s,tostring(m)))

peripheral.find("modem", rednet.open); local id=rednet.lookup("demo","A"); assert(id,"no host"); rednet.send(id,"hello from B","demo")



## Todos, plan, whatever
 - Indicators Feature with togglable modules / scripts
 - Clean up main view files, you know it's all a mess
      - [ ] Rename Experimental-Frame to smth more appropiate!
      - [ ] 

 - Networking with other nodes?
 - Build the freakking server dude, for central state yk:)
 - [NODE] Watersheep Lore
   - Say stuff in chat
   - Print chores

 - #gtmo Think about changing  

#### Branches
 - 'main': main branch
 - 'side': GregAdmin shit before it got merged
 - 'old': WorldAdmin before being overwritten by 'side'

