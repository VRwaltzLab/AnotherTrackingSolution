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

So to identify a matte color (up to 1st bounce precision), I believe we need to invert the gamma function and ???
