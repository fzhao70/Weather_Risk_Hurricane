# Hurricane Weather Risk Toy Model

## Description
Use the Algorithm listed in NOAA Technical Report NWS 38
Hurricane Climatology for the Atlantic and Gulf Coasts of the United States 

## Usage

Change the following lines in model.jl as you need
```
lat = range(20, 40, length =  200)
lon = range(-105, -75, length = 300)
track_list = ["Charley-Track", "Katrina-Track", "Wilma-Track"]
```
Then running
```
julia model.jl
python plot.py
```

## Input format
xls file input need to contains following column : 
Hour	Lon(deg)	Lat(deg)	Theta(deg)	Po(mb)	Rmax(mi)	T(kt)

