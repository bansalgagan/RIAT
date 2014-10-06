module PraxengMdpHelper

  def eig(a,b,n)
    r = RSRuby.instance
    text = "(log(#{n}) - (#{b}/(#{a}+#{b}))*log(#{n}-1) - digamma(#{a}+#{b}+1) + (#{a}*digamma(#{a}+1)+#{b}*digamma(#{b}+1))/(#{a}+#{b}))"
    val = r.eval(r.parse(:text => text))
    return val
  end
  
  def sig(a,b,n)
    r = RSRuby.instance
    text = "integrate(function(q) {((-log(#{n}) + q*log(q) + (1-q)*log((1-q)/(#{n}-1)))^2)*(q^#{a}*(1-q)^#{b}*1/beta(#{a},#{b}))}, lower = 0, upper = 1)$val"
    integ = r.eval(r.parse(:text => text))
    
    eig1 = eig(a,b,n)
    val = integ - eig1
    if val > 0
      return Math.sqrt(val)
    else
      return 0
    end
  end
  
  def digam(x)
    r = RSRuby.instance
    val = r.digamma(x)
    return val
  end
    

  def u_now_question(a,b,n)
    return eig(a,b,n)- sig(a,b,n)
  end

  def compute_utility(a,b,c,u_past_question,l)
    if l < 0
      return 0, 0, 'none'
    end
    n = 16;
    gamma = 0.5
    eig1 = eig(a,b,n)
    sig1 = sig(a,b,n)
    
    u_now_question  = eig1 - sig1
    u_now_coll = u_now_question
    u_future_coll, temp1, temp2 = compute_utility(a,b,c+1, u_now_question, l-1)
    # u_future_coll = compute_utility(a,b,c+1, u_now_question, l-1)
    u_coll = gamma*(u_now_coll + u_future_coll)
    
    q = (a+1)/(a+b+n)
    u_now_corr_question = eig(a+1, b, n) - sig(a+1, b, n)
    u_now_corr_calib = c*(u_now_corr_question - u_past_question)
    u_fut_corr_calib, temp1, temp2 = compute_utility(a+1, b, c, u_now_corr_question, l-1)
    #u_fut_corr_calib = compute_utility(a+1, b, c, u_now_corr_question, l-1)
    
    u_now_incorr_question = eig(a, b+1, n) - sig(a, b+1, n)
    u_now_incorr_calib = c*(u_now_incorr_question - u_past_question)
    u_fut_incorr_calib, temp1, temp2 = compute_utility(a, b+1, c, u_now_incorr_question, l-1)
    #u_fut_incorr_calib = compute_utility(a, b+1, c, u_now_incorr_question, l-1)
    
    u_calib = gamma*(q*(u_fut_corr_calib + u_now_corr_calib) + (1-q)*(u_fut_incorr_calib + u_now_incorr_calib))
    
    u_total = 0
    if u_calib > u_coll
      action = 'calib'
      u_total = u_calib
    else
      action = 'coll'
      u_total = u_coll
    end
    return u_total, u_now_question, action
  end

end
