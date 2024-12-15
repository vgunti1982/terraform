#-------------------------------------
#LAB 1b
provider "signalfx" {
  auth_token = "TOKEN HERE"
  api_url="https://api.REALM.signalfx.com"
}

#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE
resource "signalfx_time_chart" "tfchart_01" {
    name = "XXX_TF_CPU Utilization"
    program_text = <<-EOF
        data("cpu.utilization").publish(label= "cpu")
        EOF
    plot_type = "LineChart"
    show_data_markers = true
}

#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE
resource "signalfx_time_chart" "tfchart_02" {
    name = "XXX_TF_Memory Utilization"
    program_text = <<-EOF
        data("memory.utilization").publish(label= "memory")
        EOF
    plot_type = "AreaChart"
    show_data_markers = true
}

#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE
resource "signalfx_time_chart" "tfchart_03" {
    name = "XXX_TF_Latency"
    program_text = <<-EOF
        data("dem_latency").publish(label= "latency")
        EOF
    plot_type = "LineChart"
    show_data_markers = true
}

#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE
resource "signalfx_time_chart" "tfchart_04" {
    name = "XXX_TF_Number of API Calls"
    program_text = <<-EOF
        data("dem_numcalls").publish(label= "API Calls")
        EOF
    plot_type = "ColumnChart"
    show_data_markers = true
}

