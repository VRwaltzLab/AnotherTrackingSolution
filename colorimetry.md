# Problem
How do we determine the units of something being green?

## Formulation attempt:
We have a light source A which has photon distributuion a or a(distance) (a distribution on wavelength which has units in photons or something)
Which then hits an object O which has reflectance distribution o(incident_angle,exit_angle).
(ASSUMING NO INTERFERENCE BETWEEN RELFECTIONS)
They combine to form the single bounce photon distribution heading toward a camera from a object originally from a source.
 a(distance) hadmard product with o(incident_angle,exit_angle).
Which then hits a sensor S with receptor distribution s in terms of wavelength and response to quantity of light gamma g.
``` g ( s^T Sum_over_angles( o( incident_angle,exit_angle) hadmard_product a(distance)) )``` 
I am under the impression that when we say something has a matte color 
when the reflectance distribution is merely scaled by some function of incident and exit angle.
I would guess that setting the white balance accounts for A's distribution.
So to identify a matte color (up to 1st bounce precision) in a white-balanced camera,
I believe we need to invert the gamma function then we can put it on a 2d plane ```R/(R+G+B), B/(R+G+B) ```
And we label a color by a region of this 2D plane (so that we can ignore the distance and angle dependence of the equations)


I think this is a good enough idea for a first attempt.

### Note
Lambertian surfaces are the precise term for the kind of matte-ness I was getting at.
It might be better do compute R/G and R/G rather R/(R+G+B) and B/(R+B+G)...
That seems like a more numerically stable equation when something reflects some amount of green light.
For a sufficiently lambertian surface (like cotton balls), this should divide out the distance and angle effects on color.
 
