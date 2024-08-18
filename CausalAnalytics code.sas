cas mySession sessopts=(caslib=casuser timeout=2400 locale="en_US" metrics='true');
caslib _all_ assign;

cas;
caslib _all_ assign;

ods graphics on;
title 'Using SAS9 ETS Proc Model with SAS Studio in Viya';

data work.import_new;
     set work.import;
est_spend_num = input(est_spend,dollar9.);
run;


proc summary data= Work.import_new;    
class Week;
var Agent_Tenure Customer_Tenure est_spend_num category_1 category_2 category_3 category_4 P_NPS_Detract_Pass_ProPROMOTERS;
output out = work.import_new2 (drop= Agent_Tenure Customer_Tenure est_spend_num category_1 category_2 category_3 category_4) 
 mean = mean(Agent_Tenure)= avg_agent_tenure
  mean = mean(Customer_Tenure)= avg_customer_tenure
  mean = mean(est_spend_num)= avg_est_spend_num
  sum =  sum(category_1) = sum_category_1
  sum =  sum(category_2) = sum_category_2
  sum =  sum(category_3) = sum_category_3
  sum =  sum(category_4) = sum_category_4;    
run;

ods graphics on;

proc model data=work.import_new2 plots=all;
var b0 b1 b2 b3 b4 b5 b6 b7;
label b0 = 'Intercept'
      b1 = 'Avg_AgentTenure'
      b2 = 'Avg_CustomerTenure'
      b3 = 'Avg_est_spend'
      b4 = 'Sum_cat1'
      b5 = 'Sum_cat2'
      b6 = 'Sum_cat3'
      b7 = 'Sum_cat4';
P_NPS_Detract_Pass_ProPROMOTERS = b0 + b1*avg_agent_tenure + b2*avg_customer_tenure + b3*avg_est_spend_num + 
b4*sum_category_1 + b5*sum_category_2 + b6*sum_category_3 + b7*sum_category_4;
fit P_NPS_Detract_Pass_ProPROMOTERS /white breusch=(1 income) out=casuser.econ_output 
outpredict outactual details; 

weight _freq_;
//**estimate 'Safe/Easy -10%, Prob+10%' b0 + b1*(597.42)*1.1 + b2*(1635.69)*1.1 + b3*(471.44)*0.9 + b4*(9643)*0.9 +
               b5*(7399)*0.9 + b6*(18006)*1.1 + b7*(10624)*0.9;**//
estimate 'Safe/Easy no change' b0 + b1*(597.42) + b2*(1635.69) + b3*(471.44) + b4*(9643) +
               b5*(7399) + b6*(18006) + b7*(10624);
title 'Proc Model for Simple Linear Combinations';
run;
title;
ods graphics off;


