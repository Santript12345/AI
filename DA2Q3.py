import numpy as np

# Probabilities
P_Cloudy = 0.5
P_Sprinkler_given_Cloudy = {True: 0.1, False: 0.5}
P_Rain_given_Cloudy = {True: 0.8, False: 0.2}
P_WetGrass_given_Sprinkler_Rain = {
    (True, True): 0.99,
    (True, False): 0.90,
    (False, True): 0.80,
    (False, False): 0.00
}

# Monte Carlo Simulation
def monte_carlo_simulation(num_samples=10000):
    count_wet_grass_given_rain = 0
    count_rain = 0

    for _ in range(num_samples):
        # Determine if it is cloudy
        cloudy = np.random.rand() < P_Cloudy
        
        # Determine if the sprinkler is on, given whether it is cloudy
        sprinkler = np.random.rand() < P_Sprinkler_given_Cloudy[cloudy]
        
        # Determine if it is raining, given whether it is cloudy
        rain = np.random.rand() < P_Rain_given_Cloudy[cloudy]
        
        # Determine if the grass is wet, given the sprinkler and rain states
        wet_grass = np.random.rand() < P_WetGrass_given_Sprinkler_Rain[(sprinkler, rain)]
        
        # Count occurrences of rain and wet grass given rain
        if rain:
            count_rain += 1
            if wet_grass:
                count_wet_grass_given_rain += 1

    # Estimate the probability
    return count_wet_grass_given_rain / count_rain if count_rain > 0 else 0

# Run the simulation and print the result
print(f"Estimated Probability: {monte_carlo_simulation()}")
