# Mohr-Coulomb yield plsticity
# Young's Modulus = 1.2e9 Pa
# Passion's ratio = 0.3
# Friction angle = 32 degree
# Dilation angle = 10 degree
# Cohesion = 0.24e6 Pa
# \ref{'Three-dimensional numerical simulation of rock deformation in bolt-supported tunnels: A homogenization approach Author links open overlay panel'}
# Scenario: 100m depth in mudstone
# Unit weight of mudstone is 24KN/m^3
# The vertical stress is 2.4 MPa = horizontal stress

[Mesh]
  file = middle_bottom_node.msh
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Variables] #Block for the main variable (displacement), for auxiliary variables using [AxuVariables]
  [disp_x] # Define the interpolation functions
    order = FIRST
    family = LAGRANGE
  []
  [disp_y] # Define the interpolation functions
    order = FIRST
    family = LAGRANGE
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        strain = FINITE
        incremental = true
        add_variables = true
        generate_output = 'strain_xx strain_xy strain_yx strain_yy stress_xx stress_xy stress_yx stress_yy vonmises_stress max_principal_stress min_principal_stress max_principal_strain min_principal_strain radial_stress radial_strain hoop_stress hoop_strain spherical_hoop_stress spherical_hoop_strain plastic_strain_xx l2norm_plastic_strain'
        material_output_family = 'MONOMIAL'
        material_output_order = 'FIRST'
      []
    []
  []
[]

[BCs]
  [top_stress]
    type = Pressure
    variable = disp_y
    boundary = 'top'
    factor = 2.4e6 # pa
  []
  [left_stress]
    type = Pressure
    variable = disp_x
    boundary = 'left'
    factor = 2.4e6 # pa
  []
  [right_stress]
    type = Pressure
    variable = disp_x
    boundary = 'right'
    factor = 2.4e6 # pa
  []
  [CavityPressure_x]
    type = Pressure
    boundary = 'inner'
    displacements = 'disp_x disp_y'
    variable = disp_x
    factor = 4e4 # pa
  []
  [CavityPressure_y]
    type = Pressure
    boundary = 'inner'
    displacements = 'disp_x disp_y'
    variable = disp_y
    factor = 4e4 # pa
  []
  [bottom_dispy]
    type = DirichletBC
    boundary = 'bottom'
    value = 0
    variable = disp_y
  []
  [bottom_dispx]
    type = DirichletBC
    boundary = 'middle_bottom'
    value = 0
    variable = disp_x
  []
[]

[ICs]
  [ic_ux]
    type = ConstantIC
    variable = disp_x
    value = 0.0
  []
  [ic_uy]
    type = ConstantIC
    variable = disp_y
    value = 0.0
  []
[]

[UserObjects]
  [coh]
    type = SolidMechanicsHardeningConstant
    value = 0.24e6
  []
  [phi] # By setting the dilation angle equal to friction angle, it will be easier problem to solve for MOOSE
    type = SolidMechanicsHardeningConstant
    value = 32
    convert_to_radians = true
  []
  [psi]
    type = SolidMechanicsHardeningConstant
    value = 16 # Defines hardening of the dilation angle (in radians)
    convert_to_radians = true
  []
  [mc]
    type = SolidMechanicsPlasticMohrCoulomb # Non-associative Mohr-Coulomb plasticity with hardening/softening
    cohesion = coh # Cohesion
    friction_angle = phi # Internal friction angle
    dilation_angle = psi # Dilation angle
    mc_tip_smoother = 0.24e5 # Smoothing parameter: the cone vertex at mean = cohesion*cot(friction_angle), will be smoothed by the given amount. Typical value is 0.1*cohesion
    mc_edge_smoother = 29
    yield_function_tolerance = 1E-8 # If the yield function is less than this amount, the (stress, internal parameter) are deemed admissible.
    internal_constraint_tolerance = 1E-8 # The Newton-Raphson process is only deemed converged if the internal constraint is less than this.
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1.2e9 # Pa
    poissons_ratio = 0.3
  []
  [mc]
    type = ComputeMultiPlasticityStress
    ep_plastic_tolerance = 1e-11
    plastic_models = mc # Defined in UserObjects, Mohr-Coulomb yield surface
  []
[]
# Do not use 'IsotropicPlasticityStressUpdate' cause the yield surface used is the Von Mises yield surface..Using 'ComputeMultiPlasticityStress'.

[Executioner]
  type = Steady
[]

[Outputs]
  exodus = true
[]

# Mohr-Coulomb: 'materials/CappedMohrCoulombStressUpdate' or 'userobjects/SolidMechanicsPlasticMohrCoulomb'
