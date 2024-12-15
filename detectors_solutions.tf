#LAB 4a - CREATE SIMPLE DETECTOR 
resource "signalfx_detector" "det_01" {

  name        = "XXX_TF_p99 Memory by Datacenter"
  description = "p99 Memory Utilization is high in a datacenter"
  
  program_text = <<-EOF
        A = data('memory.utilization').percentile(99, by=['datacenter']).publish()
        #detect(when(A > 90,'5m')).publish('p99 of memory by datacenter')
        detect(when(A > 90,'5m'), off=when(A < 50,'5m')).publish('p99 of memory by datacenter')
        EOF
  
  rule {    
    description   = "p99 of memory > 90"
    severity      = "Critical"
    detect_label  = "p99 of memory by datacenter"
    #Replace the team IDs with the IDs of team(s) that you want notified
    #REPLACE ID FROM THE UI
    notifications = ["Team,EjGh3bhAYAA"]
  }
}

#--------------------------------------------
#LAB 4b - CREATE DETECTOR WITH MULTIPLE RULES
resource "signalfx_detector" "det_02" {

  name        = "XXX_TF_Memory usage of a container"
  description = "High memory usage of a container"

  program_text = <<-EOF
        A = data('memory.usage.limit').publish()
        B = data('memory.usage.total').publish()
        C = (100*(A-B)/A).publish()
        detect(when(C> 70,'5m')).publish('container mem-critical')
        detect(when(50 < C and C <= 70,'10m')).publish('container mem-major')
        EOF
  
  rule {
    description   = "mem usage > 70"
    severity      = "Critical"
    detect_label  = "container mem-critical"
  }
  rule {
    description   = "50 < mem usage < 70"
    severity      = "Major"
    detect_label  = "container mem-major"
  }
}


#--------------------------------------------
#LAB 4c - CREATE MUTING RULE

resource "signalfx_alert_muting_rule" "muting_01" {
  description = "XXX_TF_Testing muting rule"

  start_time = 1601380800  #<ADD START TIME IN UNIX SECONDS>
  stop_time  = 1601467200 # Defaults to 0 <ADD STOP TIME IN UNIX SECONDS>

  detectors = [signalfx_detector.det_01.id]

  filter {
    property       = "service_type"
    property_value = "production"
  }
}



