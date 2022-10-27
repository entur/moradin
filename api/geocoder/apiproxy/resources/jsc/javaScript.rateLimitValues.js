var etClientName = context.getVariable("request.header.et-client-name")
var etClientType = context.getVariable("request.header.et-client-type")

var nsb = { quota: "4000", spikeArrest: "200ps" };
var ruter = { quota: "6000", spikeArrest: "400ps" };
var skyss = { quota: "2000", spikeArrest: "200ps" };
var entur = { quota: "4000", spikeArrest: "400ps" };
var atb = { quota: "4000", spikeArrest: "200ps" };
var others = { quota: "1000", spikeArrest: "100ps" };
var noIdUser = { quota: "300", spikeArrest: "10ps" };


if (etClientName) { // if client identified
  limitValues = allowedQuota(etClientName, nsb, ruter, skyss, entur,atb, others);
  quotaAllowed = limitValues.quotaAllowed;
  spikeArrestAllowed = limitValues.spikeArrestAllowed;
} else { // if not identified -> rate on ip
  etClientName = "unkown-" + context.getVariable("client.ip")
  quotaAllowed = noIdUser.quota;
  spikeArrestAllowed = noIdUser.spikeArrest;
  // Add et-client-name with ip
  context.setVariable("request.header.Et-Client-Name", etClientName);
}


// Set quota 
context.setVariable("quota.client.identifier", etClientName);
context.setVariable("quota.client.allowed", quotaAllowed);
context.setVariable("spikeArrest.client.allowed", spikeArrestAllowed);


// Get quota and spikearrest values
function allowedQuota(etClientName, nsb, ruter, skyss, entur,atb, others) {
  if (etClientName.includes("nsb")) {  // if nsb
    quotaAllowed = nsb.quota;
    spikeArrestAllowed = nsb.spikeArrest;
  } else if (etClientName.includes("ruter")) { // if ruter
    quotaAllowed = ruter.quota;
    spikeArrestAllowed = ruter.spikeArrest;
  } else if (etClientName.includes("skyss")) { // if skyss
    quotaAllowed = skyss.quota;
    spikeArrestAllowed = skyss.spikeArrest;
  } else if (etClientName.includes("entur")) { // if entur
    quotaAllowed = entur.quota;
    spikeArrestAllowed = entur.spikeArrest;
  } else if (etClientName.includes("atb")) { // if atb
    quotaAllowed = atb.quota;
    spikeArrestAllowed = atb.spikeArrest;
  } else { // if other
    quotaAllowed = others.quota;
    spikeArrestAllowed = others.spikeArrest;
  }
  return {
    quotaAllowed: quotaAllowed,
    spikeArrestAllowed: spikeArrestAllowed
  };
}