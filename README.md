# WEATHER TO WALK OR RUN IN THE RAIN

## A numerical approach to a practical problem  
**Simone Albano**  
**December, 2024**

---

## Chapter 1: Method Introduction

The question we aim to address in this short document is whether it is better to walk or run when caught in the rain. Conducting real tests with actual rain would be both impractical and time-consuming, so we will attempt to answer this question through numerical simulations.

We will also explore whether factors such as the horizontal speed and angle of the rain significantly impact the outcome. Additionally, we will investigate whether varying the proportions of the object used to simulate the human body can help minimize exposure to raindrops.

---

## 1.1 Rain Generation Algorithm

We will start our investigation by creating a virtual rainy environment using MATLAB. The simulation box is defined as the rectangular domain within which all raindrops are considered "active." This means we will only count the raindrops that hit the object emulating the human body when it is inside the simulation box. 

### Key Algorithm Steps:
1. At each discrete time step \( t_k \), a new vector of raindrops of length \( N \) is generated.
2. Raindrops are positioned at the highest \( y \)-coordinate of the simulation box, with Gaussian noise added for realism.
3. The rain velocity parameter \( V_r \) maintains a constant vertical component to ensure consistent rain density.
4. Raindrops exiting the bottom or colliding with the test object are removed.

The horizontal velocity of the rain (\( V_{\text{rain}, x} \)) is derived using the rain angle \( \vartheta_r \):

\[
V_{\text{rain}, x} = \frac{V_{\text{rain}, y}}{\tan(\vartheta_r - \frac{\pi}{2})}
\]

A height-to-thickness ratio of 6 is used to simulate the human body. Further simulations are performed with a ratio of 1:3 to emulate a cat's proportions.

---

### Example Simulation:

![Simulation Example](Figure 1.1)

- **Simulation Box Dimensions**: \([10, 20] \times [0, 5.5]\)  
- **Rain Generation Interval**: \( x \in [0, 30] \), \( y = 5.5 \)  
- **Rain Velocity**: \( V_{\text{rain}, y} = -0.150 \text{ m/s} \)  
- **Body Rectangle Dimensions**: \( L = 0.83 \text{ m}, H = 5 \text{ m} \)

---

## 1.2 Results for the Human Body

### Simulation Details:
- **Number of Simulations**: 4096  
- **Rain Angle Range**: \( \vartheta_r \in [-\frac{\pi}{3}, \frac{\pi}{3}] \)  
- **Object Velocity Range**: \( V_{\text{obj}, x} \in [0.005, 0.3] \text{ m/s} \)

### Observations:
1. **Optimal Speed**: Matching the horizontal component of the rain’s velocity minimizes exposure.  
2. Traveling faster than optimal speed provides minimal additional benefit.  

---

## 1.3 Results for the Cat-Shaped Body

Using a cat-shaped rectangle, the dependence of rain flux density on speed diminishes. This is attributed to the smaller front and back surfaces compared to the top, which remains exposed.

---

## 1.4 Conclusions

1. Matching speed to the horizontal rain velocity minimizes rain exposure.  
2. For negative rain angles, running faster always reduces exposure.  
3. Cat-shaped objects show reduced sensitivity to horizontal speed due to their proportions.

---

## Additional Figures

![Human Body Simulation](Figure 1.6)  
![Cat Body Simulation](Figure 1.8)

---

**Note**: Additional plots and figures produced during the simulations are available in the supplementary materials.
