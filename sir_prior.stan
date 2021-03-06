//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

functions {
  real[] sir(real t, real[] y, real[] theta, 
             real[] x_r, int[] x_i) {

      real S = y[1];
      real I = y[2];
      real R = y[3];
      real N = x_i[1];
      
      real beta = theta[1];
      real gamma = theta[2];
      
      real dS_dt = -beta * I * S / N;
      real dI_dt =  beta * I * S / N - gamma * I;
      real dR_dt =  gamma * I;
      
      return {dS_dt, dI_dt, dR_dt};
  }
}


data {
  int<lower=1> n_days;
  real y0[3];
  real t0;
  real ts[n_days];
  int N;
  int cases[n_days];
}

transformed data {
  real x_r[0];
  int x_i[1];
  x_i[1]=N;
}

parameters {
  real<lower=0> gamma_inv;
  real<lower=0> beta;
  real<lower=0> phi_inv;
}

transformed parameters{
  real y[n_days,3];
  real phi = 1. / phi_inv;
  real gamma = 1. / gamma_inv;
  {
    real theta[2];
    theta[1] = beta;
    theta[2] = gamma;

    y = integrate_ode_rk45(sir, y0, t0, ts, theta, x_r, x_i);
  }
}


model {
  beta ~ normal(0.55, 0.18);
  gamma_inv ~ normal(6.4, 1.5);
  //gamma ~ gamma(0.004,0.02);

  //col(matrix x, int n) - The n-th column of matrix x
  phi_inv ~ exponential(1);

}

generated quantities {
  real R0 = beta/gamma;
  real recovery_time = 1/gamma;
  real pred_cases[n_days];
  pred_cases = neg_binomial_2_rng(col(to_matrix(y),2) + 1e-5, phi);
}

