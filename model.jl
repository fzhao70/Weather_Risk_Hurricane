using ExcelReaders
using NPZ
using Plots

lat = range(20, 40, length =  200)
lon = range(-105, -75, length = 300)
track_list = ["Charley-Track", "Katrina-Track", "Wilma-Track"]

function meshgrid(vx, vy)
    m, n = length(vy), length(vx)
    vx = reshape(vx, 1, n)
    vy = reshape(vy, m, 1)
    (repeat(vx, m, 1), repeat(vy, 1, n))
end

function distance(lon1, lat1, lon2, lat2)
    R_e = 6371 * 1000
    dlon = deg2rad(lon2 - lon1)
    dlat = deg2rad(lat2 - lat1)
    a = sin(dlat / 2)^2 + cosd(lat1) * cosd(lat2) * sin(dlon / 2)^2
    c = 2 * atan(sqrt(a), sqrt(1 - a))
    return R_e * c # in m
end

function f(lat)
    #in rad/s
    return 2 * 2 * pi / 24 * sin(lat)
end

function phi(r)
    #in deg
    return -12.022 + 9.018 * log(r)
end

for track_name in track_list
    input_data = readxlsheet(track_name * ".xls", "Sheet1")
    nt = size(input_data)[1] - 1
    grid = zeros(Float64, (nt, 300, 200))

    for t = 1:nt
        lon_c = input_data[t + 1, 2]
        lat_c = input_data[t + 1, 3]
        theta = input_data[t + 1, 4]
        Po    = input_data[t + 1, 5]
        Rmax  = input_data[t + 1, 6]
        T     = input_data[t + 1, 7]
    
        Rmax = Rmax * 1609 # in meter
        Po = Po / 10.2     # in kg / m^2
    
        P_surface = 1013 / 10.2 # in kg / m^2
        denisty = 1.225         # kg / m3
        Rlimit = 350 * 1000     # in meter
    
        if theta > 0
            theta_p = theta
        else
            theta_p = 360 + theta
        end
    
        for i = 1:300, j = 1:200
             r = distance(lon[i], lat[j], lon_c, lat_c) # in meter
             Vg_x = (1 / denisty / exp(1))^(1/2) * ((P_surface - Po) / exp(-1 * Rmax / r))^(1/2) - (Rmax * f(lat[j]) / 2) # in m/s
    
             V_xs = 0.9 * Vg_x # m / s
             a = rad2deg(atan((lat[j] - lat_c) / (cos(deg2rad(lat_c)) * (lon[i] - lon_c)))) # in deg
    
             if lon[i] > lon_c
                cosb = cosd(a + phi(r) +  theta_p)
             else
               cosb = -1 * cosd(a + phi(r) +  theta_p)
             end
    
    
             if r >= Rlimit
                grid[t, i, j] = 0
             end
             if Rmax < r <= Rlimit
                V_s = V_xs * exp(-1 * ((r - Rmax) / 120)^1.2)   # m/s
                V_s = V_s * 1.943                               # in knots
                V = V_s + 1.5 * (T^0.63) * cosb                 # in knots
                V_k = 0.89 * V                                  # in knots
                grid[t, i, j] = 1.2 * V_k                       # in knots
             end
             if 0 <= r <= Rmax
                V_s = V_xs * (r / Rmax)^1.2                     # m/s
                V_s = V_s * 1.943                               # in knots
                V = V_s + 1.5 * (T^0.63) * cosb                 # in knots
                V_k = 0.89 * V                                  # in knots
                grid[t, i, j] = 1.2 * V_k                       # in knots
             end
        end
    end
    
    lon2d, lat2d = meshgrid(lon, lat)
    npzwrite("lon.npy", lon2d)
    npzwrite("lat.npy", lat2d)
    npzwrite(track_name * ".npy", grid)

end
