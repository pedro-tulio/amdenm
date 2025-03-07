# Adaptive MDeNM User Guide

The MDeNM (Molecular Dynamics with excited Normal Modes) method consists of multiple-replica short MD simulations in which motions described by a given subset of low-frequency NMs are kinetically excited. This is achieved by adding additional atomic velocities along several randomly determined linear combinations of NM vectors, thus allowing an efficient coupling between slow and fast motions.

This new approach, aMDeNM, automatically controls the energy injection and take the natural constraints imposed by the structure and the environment into account during protein conformational sampling, which prevent structural distortions all along the simulation.Due to the stochasticity of thermal motions, NM eigenvectors move away from the original directions when used to displace the protein, since the structure evolves into other potential energy wells. Therefore, the displacement along the modes is valid for small distances, but the displacement along greater distances may deform the structure of the protein if no care is taken. The advantage of this methodology is to adaptively change the direction used to displace the system, taking into account the structural and energetic constraints imposed by the system itself and the medium, which allows the system to explore new pathways.

This document will give an overview of the Adaptive MDeNM method and help to properly setup and run a simulation.
* ****

#### Table of Contents
<!-- TOC START min:1 max:3 link:true asterisk:false update:true -->
- [Adaptive MDeNM User Guide](#adaptive-mdenm-user-guide)
      - [Table of Contents](#table-of-contents)
  - [Method Overview](#method-overview)
    - [RMSD Filtering](#rmsd-filtering)
    - [Kinetic Energy Control](#kinetic-energy-control)
    - [Excitation Direction Update](#excitation-direction-update)
  - [MDeNM Applications](#mdenm-applications)
    - [Physical force-field based normal modes](#physical-force-field-based-normal-modes)
    - [Elastic network models](#elastic-network-models)
    - [Dihedral angles perturbations *(beta)*](#dihedral-angles-perturbations-beta)
    - [PFF modes combined with local normal modes *(beta)*](#pff-modes-combined-with-local-normal-modes-beta)
    - [PFF modes combined with dihedral angles partubations *(beta)*](#pff-modes-combined-with-dihedral-angles-partubations-beta)
    - [Combining two different sets of PFF modes *(beta)*](#combining-two-different-sets-of-pff-modes-beta)
    - [Customized user-provided vectors](#customized-user-provided-vectors)
    - [PFF modes combined with custom vectors *(beta)*](#pff-modes-combined-with-custom-vectors-beta)
    - [Custom modes combined with local normal modes *(beta)*](#custom-modes-combined-with-local-normal-modes-beta)
    - [Custom modes combined with dihedral angles partubations *(beta)*](#custom-modes-combined-with-dihedral-angles-partubations-beta)
  - [Preparing to run MDeNM](#preparing-to-run-mdenm)
    - [CHARMM input files](#charmm-input-files)
    - [Adaptive MDeNM files](#adaptive-mdenm-files)
    - [Configuration](#configuration)
    - [Job models](#job-models)
    - [Restarting a MDeNM run](#restarting-a-mdenm-run)
  - [Analysis](#analysis)
  - [Citing](#citing)
  - [Contact](#contact)
<!-- TOC END -->
* ****

## Method Overview
The Molecular Dynamics with excited Normal Modes (MDeNM) is a enhanced sampling molecular dynamics method that uses normal modes as collective variables in order do increase the conformational space explored during MD simulation. This is done by injecting an incremental energy to the system, thus assigning additional atomic velocities along the direction of a given NM (or a combination of a NM set). The combination of the velocities from MD and those provided by the NM vectors properly couple slow and fast motions, allowing one to obtain large time scale movements, such as domain transitions in a feasible simulation time.

### RMSD Filtering
An optmized MDeNM run is ensured by evaluating the excitation directions through a RMSD threshold (*t*) - that is user defined. During the run, a hypersphere with radius *1 Å* is set up around the reference position. Each point at its surface represents a different possible NM combination. When searching for a new NM combination, the structure is displaced along this direction untill it reaches the hypersphere's surface. Then, its RMSD value is tested against all previously accepted directions. If this value is equal or greater than *t*, this new vector is retained. Otherwise, a new combination must be computed. This step avoids redundant directions to be excited during the simulation, thus improving the computing time.

### Kinetic Energy Control
The additional kinetic energy injected in the system has a fast dissipation rate. Therefore, the program constantly checks the injection energy level and rescale the velocities along the excited direction whenever it is necessary. With this procedure, the system is kept in a continuous excited state, allowing an effective small, "adiabatic-like" energy injection. The energy injection control is done by projecting the velocities computed during the simulation onto the excited vector, thus obtaining and rescaling the kinetic energy corresponding to it.

### Excitation Direction Update
Since the excitation vector is obtained from the initial conformation, it is dependent of this configuration. As the system is displaced along this direction and change its conformation, the motion loses its directionality due to mainly anharmonic effects. To prevent the structural distortions produced by the displacement along a vector that is no longer valid, the program update the excitation directions based on the trajectory evolution during the previous excitation steps. This procedure allows the system to adaptively find a relaxed path to follow during the next MDeNM excitations.

The update depends on two variables: a distance (*r<sub>d</sub>*) by which the system has been displaced along the excitation vector; and a given angle (*α*) by which the real displacement has deviated from the ideal motion described by the excitation vector. Everytime the system reaches a displacement equals to *r<sub>d</sub>* along the excitation direction, the *α* angle is computed. If the deviation is lesser than a threshold value, the current direction is retained and the simulation resumes. Otherwise, a new vector is generated considering the motion presented by the system in the last excitation steps. The default values for *r<sub>d</sub>* and *α* are *0.5 Å* and *60°*, respectively.

[Back to top ↩](#)
* ****

## MDeNM Applications
The Adaptive MDeNM method has several biult-in applications, each one using different inputs as collective variables to increase the MD sampling.

### Physical force-field based normal modes
Uses physical force-field based normal modes computed in *[CHARMM](https://www.charmm.org/charmm/)*. A given normal mode (or a linear combination of several modes) is used to excite the system during the molecular dyamics simulation.

### Elastic network models
Uses elastic network models computed with *[elNémo](http://www.sciences.univ-nantes.fr/elnemo/)*.

### Dihedral angles perturbations *(beta)*
Uses dihedral angle perturbations to excite the system.

### PFF modes combined with local normal modes *(beta)*
Excites two different regions of the system, using PFF modes as the global excitation and local modes to excite a user-given region of the system.

### PFF modes combined with dihedral angles partubations *(beta)*
Excites two different regions of the system, using PFF modes as the global excitation and dihedral angles perturbations to excite a user-given region of the system.

### Combining two different sets of PFF modes *(beta)*
Excites two different regions of the system, using two different sets of PFF modes to excite the system globally and locally.

### Customized user-provided vectors
This MDeNM application uses normal modes vectors computed in elsewhere rather than CHARMM as long as they are provided on CHARMM .crd extension or *[.xyz chemical file format](http://openbabel.org/wiki/XYZ_(format))*.

### PFF modes combined with custom vectors *(beta)*
Excites two different regions of the system, using PFF modes as the global excitation and custom vectors to excite a user-given region of the system.

### Custom modes combined with local normal modes *(beta)*
Excites two different regions of the system, using custom vectors as the global excitation and local modes to excite a user-given region of the system.

### Custom modes combined with dihedral angles partubations *(beta)*
Excites two different regions of the system, using custom vectors as the global excitation and dihedral angles perturbations to excite a user-given region of the system.

[Back to top ↩](#)
* ****

## Preparing to run MDeNM
The Adaptive MDeNM simulations are done using CHARMM. Therefore, you must have it installed in your machine. Parallel run is supported by installing CHARMM with MPI.

### CHARMM input files
This is a prerequired step to perform MDeNM simulations. It consists in independently:
* performing a short equilibration MD to store the final atomic velocities and positions;
* computing the normal modes from the last MD coordinates, storing vectors from the low-frequency end of the vibrational spectrum.

MDeNM will require the following CHARMM files to properly run:
* a psf file containing the system topology;
* a restart file containing the positions and velocities from MD;
* a stream file containing the box information;
* a stream file containing the crystal symmetry operation;
* a stream file for topology and parameter reading;
* a folder containing the parameters and topology files;
* a binary file containing the normal modes vectors.

### Adaptive MDeNM files
Adaptive MDeNM is distributed as a multifile CHARMM script. A brief description of each section is made as follows:
* **inputs:** contains the configuration file and the models to launch PBS or SLURM jobs remotely. All necessary CHARMM files will be automatically copied into this folder during the configuration;
* **src:** contains the MDeNM main script as well as the ENM and dihedral perturbation executables;
* **modules:** contains several MDeNM subroutines. Some of them are used to perform basic structural analysis on *[VMD](http://www.ks.uiuc.edu/Research/vmd/)*;
* **lib:** contains small MDeNM operations called during the simulation.

### Configuration
One can easily configure an Adaptive MDeNM run by using the configuration file provided in the *inputs* folder. In a terminal, enter the *inputs* folder and type <code>./configure -o</code>, the program will prompt the instructions and automatically edit the files. If something goes wrong during the process, cancel the editing and type <code>./configure -c</code> for clean up and start again. **Note:** make sure that the configuration file is being executed **within the *inputs*** folder.
The configuration process is straightforward. Some technical aspects will be covered in this section in order to facilitate the method comprehension.

* **Energy injection:** the excitation time of Adaptive MdeNM is *0.2 ps*. This means that every *0.2 ps* the system receives the additional amount of energy chosen by the user. Therefore, when studying large scale motions, it is advised to inject small amounts of energy in order to avoid structural distortions caused by an excessive energy injection. Usually, an excitation energy of *0.125 kcal/mol* is sufficient to achieve a large exploration of the conformational space.
* **Simulation time:** the total simulation time may require a tuning depending on the system size, energy injection and nature of the motion being excited. Considering a large scale global motion, there is a trade-off between the energy injection and the total simulation time. Larger amounts of energy allows a shorter simulation time, however, this may not be advised as discussed above.
* **RMSD filtering threshold:** the RMSD threshold defines the grid sparseness at the hypersphere surface. This value is related with the number of modes used in the combination and, by extension, with the number of replicas required to proceed with the simulation. The higher the number of modes in the combination, the higher the number of replicas necessary to properly cover the conformational space described by those modes and, thus, a smaller grid.
* **Excitation direction update:** as described above, the direction is updated after the system has traveled a distance of *0.5 Å* along the excitation vector and its real displacement has a deviation of *60°* with respect to the theoretical one. The update can also be affected by the amount of energy injected, since higher energy values leads to larger motions. In addition, after each correction the new vector loses directionality due to anharmonic effects. This means that, at a given point, the new vectors are so diffuse that there is no point in proceed the simulation. When this ponit is reached, it is necessary to recompute the normal modes and start again. This is one more reason to not inject high energy values and let the system undergoes the changes smoothly.

### Job models
The Adaptive MDeNM can be launched locally or in a HPC facility. If the working environment is a local machine, the BASH option may be chosen during the configuration. If the simulations will be carried in a HPC facility, there are two options to be chosen, based on the job scheduler and workload manager: *i) [PBS](https://www.openpbs.org/)*; or *ii) [SLURM](https://slurm.schedmd.com/)*. When the configuration is done, the simulation can be launched by tiping <code>./mdenm-run</code> in terminal at the MDeNM root directory.
**Note:** make sure to properly edit the <code>./mdenm-run</code> file providing the right path to the CHARMM executable. The *.job* files in the *input* folder might also be edited accordingly, depending on how CHARMM is installed in your HPC framework.

### Restarting a MDeNM run
If a MDeNM run eventually stops before reaching the end, the restarting is easily set by typing <code>./configure -r</code> within the *inupts* folder. It will properly reconfigure the files to resume the simulation. Similarly, it is possible to append more time to a finished simulation by running <code>./configure -a</code>. In either case, the MDeNM simulation is resumed by running <code>./mdenm-run</code> as previously done.

[Back to top ↩](#)
* ****

## Analysis
Some basic analysis are computed on-the-fly. Inside each replica folder, they can be found as follows:

* **helix.out:** total number of residues in α-helix during each MD step;
* **helix-ratio.out:** proportion of the current α-helix content with respect of the start structure;
* **sheet.out:** total number of residues in β-sheet during each MD step;
* **sheet-ratio.out:** proportion of the current β-sheet content with respect of the start structure;
* **coor-proj.out:** projection of the MD coordinates onto the normal mode space described by the excitation vector;
* **rms-proj.out:** the system RMSD displacement along the excitation vectors;
* **vp-proj.out:** projection of the MD velocities onto the normal mode space described by the excitation vector;
* **ek-proj.out:** displays the additional kinetic energy at each MD step.
* **vetors.nmd:** a file containing all excitation vectors created during the Adaptive MDeNM run to be visualized with the *[NMWiz](http://prody.csb.pitt.edu/nmwiz/)* VMD plugin.

At the end of the simulation, some structural features are computed using VMD (the input files can be found at *modules* folder):

* **rmsd.mdu:** computes the Cα RMSD during the trajectory (*trajrmsd.dat*);
* **sasa.mdu:** computes the total (*SASA_tot.dat*) and hydrophobic (*SASA_hp.dat*) solvent accessible surface area;
* **rog.mdu:** computes the protein radius of gyration (*radius_of_gyration.dat*)

**Note:** These files differs in lenght compared to the previuos ones. While the *.dat* files are computed using only the coordinates saved at the final step of each excitation, the *.out* measures are calculated during all simulation steps.

You can vizualize the trajectory of each replica with the VMD standard session available in the *inputs* directory (*visual.tcl*). Within a given replica folder, type <code>vmd -e ../inputs/visual.tcl</code> to load the files.

[Back to top ↩](#)
* ****

## Citing
Please consider to cite if you are using any Adaptive MDeNM application in your work:

[Resende-Lara, P. T. et al. *Adaptive collective motions: a hybrid method to improve conformational sampling with molecular dynamics and normal modes.* bioRxiv. doi: 10.1101/2022.11.29.517349](https://www.biorxiv.org/content/10.1101/2022.11.29.517349)

[Back to top ↩](#)
* ****

## Contact
If you experience a bug or have any doubt or suggestion, feel free to contact:

*[laraptr [at] unicamp.br](mailto:laraptr@unicamp.br)*

[Back to top ↩](#)
