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
      int N = x_i[1];
      
      real beta = theta[1];
      real gamma = theta[2];
      
      real dS_dt = -beta * I * S / N;
      real dI_dt = beta * I * S / N - gamma * I;
      real dR_dt =  gamma * I;
      
      return {dS_dt, dI_dt, dR_dt};
  }
}
data {
  int<lower=1> n_days;
  real t0;
  real y0[3];
  real ts[n_days]; //the times.
  int N;
  int cases[n_days]; //the actual data
}
transformed data {
  real x_r[0];
  int x_i[1] = { N };
}
parameters {
  real<lower=0> gamma_inv;
  real<lower=0> beta;
  real<lower=0> phi_inv;
  //real<lower=0, upper=1> p_reported; // proportion of infected (symptomatic) people reported
}
transformed parameters{
  real y[n_days, 3];
  real incidence[n_days - 1];
  real phi = 1. / phi_inv;
  real gamma = 1. / gamma_inv;
  // initial compartement values
  real theta[2] = {beta, gamma};
  y = integrate_ode_rk45(sir, y0, t0, ts, theta, x_r, x_i); //y is the number of cases in each compartment on day i.
  for (i in 1:n_days-1){
    incidence[i] =  (y[i, 1] - y[i+1, 1]);
  }
}
model {
  //prior
  beta ~ normal(0.55, 0.18);
  gamma_inv ~ normal(6.4, 1.5);


  //col(matrix x, int n) - The n-th column of matrix x
  phi_inv ~ exponential(1);


  //col(matrix x, int n) - The n-th column of matrix x. Here the number of infected people 
  cases[1:(n_days-1)] ~ neg_binomial_2(incidence, phi);
}
generated quantities {
  real R0 = beta / gamma;
  real recovery_time = 1 / gamma;
  //real incubation_time = 1 / a;
  real pred_cases[n_days-1];
  pred_cases = neg_binomial_2_rng(incidence, phi);
}



