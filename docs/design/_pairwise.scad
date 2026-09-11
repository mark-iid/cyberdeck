include <assembly.scad>
A = 0; B = 0;
if (A != B) intersection() { part(A); part(B); }
