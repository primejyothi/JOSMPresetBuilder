JOSM Preset Builder
========

Based on the data provided in a text file, build a XML file that can be  used as a preset for JOSM Editor. The following features are supported.
- Group
- Sub group
- Multi select 
- Drop down lists

#### Running jPresetGen.sh
jPresetGen.sh [-d] [-h] -i inputDataFile -o outputFile

	-h : Display the help message
	-d : Display debug messages.
	-i : Input data file
	-o : Output XML file

#### The data file
The data file contains directives and values separated by pipe symbols. The values in turn can be key=value pairs separated by commas.

##### Group Directive
group|Name : Create a group with specified name.

##### Sub group directive
subgroup|Name : Create a sub group with specified name.

##### item directive
item|key=value pairs : Create an item. The key jpField is used to create
set properties of items, create multi select or combo elements.

jpField=name : Used for the name label & type key value pairs. The type
filed can be repeated to have multiple values.

jpField=kvp : JOSM Tag key value pairs. If the value of the key is left
empty, JOSM will prompt for it when the corresponding preset is selected.

jpField=multiselect : Create a list of values from which multiple 
selections can be made. The following key value pairs can be used.
key : Name of the tag in JOSM. 
text : Name of the multi select element.
values : The list elements. Can take the form values=v1,values=v2 etc.
default : The element that will be selected by default.

jpField=combo : Create a drop down list. The following key value pairs
are supported.
key : Name of the tag in JOSM.
text : Text label for the drop down.
values : The drop down elements. Can take the form values=v1, values=v2.


##### Sample data file
```
group|AA Top Group
# subgroup | Sub group Name
subgroup|Sub group 1
# item|name=item_name,label=item_label,type=node,type=closedway|Comma separated key=value pairs|key=KeyName,text=Multi Select Name,values=sel1,values=sel2,values=sel3,default=default_value
# Avoid spaces and tabs in key value pairs. Leave value empty if value is to
# be entered manually.
# item|item 1A|Label 1A|key1A_1=,key1A_2=value1A_2,key1A_3=value1A_3|key=msKey,text=Multi Select_A,values=ms1,values=ms2,values=ms3,default=ms1|jpField=combo,key=highway,text=Type of highway,values=trunk,values=primary,values=secondary
item|jpField=name,name=item 1A,label=Label 1A,type=node,type=closedway|jpField=kvp,key1A_1=,key1A_2=value1A_2,key1A_3=value1A_3|jpField=multiselect,key=msKey,text=Multi Select_A,values=ms1,values=ms2,values=ms3,default=ms1|jpField=multiselect,key=msKey2,text=Multi Select_B,values=ms1A,values=ms2A,values=ms3A,default=ms1A|jpField=combo,key=highway,text=Type of highway,values=trunk,values=primary,values=secondary
item|jpField=name,name=item 1B,label=Label 1B,type=node|jpField=kvp,key1B_1=,key1B_2=,key1B_3=value1B_3|
subgroup|Sub group 2
item|jpField=name,name=item 2A,label=Label 2A|jpField=kvp,key2a=val2a
item|jpField=name,name=item 2B,label=Label 2B|jpField=kvp,key2b=val2b,name=|jpField=combo,key=highway,text=Type of highway,values=trunk,values=primary,values=secondary
subgroup|Sub group 3
item|jpField=name,name=item 3A,label=Label 3A|jpField=kvp,key3a=val3a
item|jpField=name,name=item 3B,label=Label 3B|jpField=kvp,key3b=val3b
```
