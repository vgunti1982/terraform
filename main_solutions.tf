#-------------------------------------
#LAB 1b
provider "signalfx" {
 auth_token = "TOKEN HERE"
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
    name = "XXX_TF_Number of API Calls TF"
    program_text = <<-EOF
        data("dem_numcalls").publish(label= "API Calls")
        EOF
    plot_type = "ColumnChart"
    show_data_markers = true
}

#-------------------------------------
#LAB 2b 
#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE
resource "signalfx_time_chart" "tfchart_05" {
    name = "XXX_TF_Latency vs Transactions"
    description = "p99 Latency vs Total number of transactions "
    program_text = <<-EOF
        data("dem_latency").percentile(99).publish(label= "p99-latency")
        data("dem_numcalls",rollup="sum").sum().publish(label= "sum-transactions")
        EOF
    plot_type = "LineChart"
    show_data_markers = true

    viz_options {
    label = "sum-transactions"
     axis  = "right"
     color = "orange"
     plot_type = "ColumnChart"
    }

}

#-------------------------------------
#LAB 2c
#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE
resource "signalfx_single_value_chart" "tfchart_06" {
    name = "XXX_TF_p99 Memory"
    description = "99th percentile of Memory utilization"
    program_text = <<-EOF
        data("memory.utilization").percentile(99).publish(label= "p99 memory")
        EOF
 
    color_by ="Scale" 

 	color_scale {
    gte = 85.0
    lte = 100.0
    color = "red"
    }

    color_scale {
    lt = 85.0
    gte = 0.0
    color = "green"
    }
    secondary_visualization = "Radial"
}

#-------------------------------------
#LAB 2d
#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE
resource "signalfx_list_chart" "tfchart_07" {
    name = "XXX_TF_%change in API Calls"
    description = "% change in total number of API calls in the last 24hours"
  
# Remove the publish() from the plots that you do not wish to display.
    program_text = <<-EOF
        A=data("dem_numcalls",rollup="sum").sum(by="dem_service")
        B=data("dem_numcalls",rollup="sum").sum(by="dem_service").timeshift('1d')
        C=((A - B)*100/B).publish(label= "%change")
        EOF

#to color by value
   	color_by ="Scale" 
#for positive % change
 	color_scale {
    gte = 0.0
    color = "green"
    }
#for negative % change    
    color_scale {
    lt = 0.0
    color = "red"
    }

#only want to display the dem_service field
    legend_options_fields {
    property = "dem_service"
    enabled  = true
    }
    legend_options_fields {
    property = "sf_metric"
    enabled  = false
    }
    legend_options_fields {
    property = "sf_originatingMetric"
    enabled  = false
    } 

#OPTIONAL TASK- To add units - %
	viz_options {
      label = "%change"
      value_suffix = "%"
    }   
}

#-------------------------------------
#Lab 2e
resource "signalfx_heatmap_chart" "tfchart_08" {
  name = "XX_TF_p99latency"
  program_text = <<-EOF
        A = data('dem_latency').percentile(99, by=['dem_service']).publish(label='p99 latency by service')
        EOF
  description = "RED = above 100ms, GREEN = below 30ms"
  disable_sampling = true
  color_scale {
    lt = 30
    color = "green"
  }
  color_scale {
    gte  = 30 
    lt   = 100
    color = "yellow"
  }
  color_scale {
    gte   = 100
    color = "red"
  }
}


#-------------------------------------
#LAB 3a
#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE
resource "signalfx_dashboard_group" "dbg0" {
   name        = "XXX_TF_Overview Dashboard Group"
   description = "This is an overview dashboard group for monitoring overall health"
    #permissions {
    #principal_id    = "abc123"
    #principal_type  = "ORG"
    #actions         = ["READ"]
  #}
    #-----------------------
    #LAB 5a - LINKING DASHBOARD GROUP TO TEAMS (uncomment the line below and replace with your team id)
    #teams = ["EhF_8E8AgAA"]
    #-----------------------
}

#Task 2
#####OVERVIEW DASHBOARD#############
#CREATING THE OVERVIEW DASHBOARD USING CHART LAYOUT
resource "signalfx_dashboard" "db01" {
    name        = "XXX_TF_Overview Dashboard"
    description = "This is an Overview DB for overall health"
    dashboard_group = signalfx_dashboard_group.dbg0.id

    chart {
    chart_id = signalfx_time_chart.tfchart_01.id
    width    = 6
    height   = 1
    column = 0
    }
    chart {
    chart_id = signalfx_time_chart.tfchart_02.id
    width    = 6
    height   = 1
    column = 6
    }
    chart {
    chart_id = signalfx_single_value_chart.tfchart_06.id
    width    = 3
    height   = 1
    column = 0
    row = 1
  }


#Task 3
###BUSINESS METRICS DASHBOARD#############
#CREATING THE BUSINESS METRICS DASHBOARD - 
# USE ONLY ONE OF GRID OR COLUMN. BOTH EXAMPLES ARE DEFINED BELOW 
resource "signalfx_dashboard" "db02" {
  name            = "XXX_TF_Business Metrics Dashboard"
  dashboard_group = signalfx_dashboard_group.dbg0.id

#USING GRID LAYOUT
 #grid {
 #  chart_ids = [
 #       signalfx_time_chart.tfchart_03.id,
 #       signalfx_time_chart.tfchart_04.id,
 #       signalfx_time_chart.tfchart_05.id,
 #       signalfx_list_chart.tfchart_07.id
 #   ]
 #   width  = 3
 #   height = 1
 #}

# USING COLUMN LAYOUT
column {
    chart_ids = [signalfx_time_chart.tfchart_03.id]
    width     = 4
  }
  column {
    chart_ids = [signalfx_time_chart.tfchart_04.id]
    width     = 4
  }
column {
    chart_ids = [signalfx_time_chart.tfchart_05.id]
    column    = 5
    width     = 3
  }
  column {
    chart_ids = [signalfx_list_chart.tfchart_07.id]
    column    = 5
    width     = 3
  }

#Task 4: TO ADD A TIME RANGE 
    time_range      = "-12h"

#TO ADD A FILTER
    filter {
        property = "dem_service"
        values   = ["login"]
    }

}

#Task 5: TO ADD A DASHBOARD VARIABLE 
  variable {
    property = "datacenter"
    alias    = "Datacenter Name"
    apply_if_exist =true
   }

#-------------------------------------
#ADDTIONAL CHARTS TO ADD TO THE OVERVIEW DASHBOARD 
#COPY THESE CHARTS TO YOUR FILE - main.tf
#REPLACE XXX WITH YOUR INITIALS TO MAKE THIS UNIQUE IN THE USER INTERFACE    
resource "signalfx_list_chart" "tfchart_08" {
    name = "XXX_TF_p99 Latency By Service"
    program_text = <<-EOF
        data("dem_latency").percentile(99,by="dem_service").publish(label= "latency_by_service")
        EOF
    legend_options_fields {
    property = "dem_service"
    enabled  = true
    }
    legend_options_fields {
    property = "sf_metric"
    enabled  = false
    }
    legend_options_fields {
    property = "sf_originatingMetric"
    enabled  = false
    } 
}


#Lab 3c Configuring Permissions on a Dashboard Group
#Add the permissions block to your dashboard group
resource "signalfx_dashboard_group" "dbg0" {
    name = "XXX_TF_Overview Dashboard Group"
    description = "This is an overview dashboard for monitoring overall health"
  
   permissions {
    principal_id    = "ExLse_fAwAU"
    principal_type  = "ORG"
    actions         = ["READ","WRITE"]
  }

}

#Lab 3d Configuring Permissions on a Dashboard 
resource "signalfx_dashboard" "grid_example" {
  name            = "Grid Example TF"
  dashboard_group = signalfx_dashboard_group.dbg0.id
  time_range      = "-15m"

  grid {
    chart_ids = [
        signalfx_time_chart.tfchart_04.id,
        signalfx_single_value_chart.tfchart_06.id
    ]
    width  = 5
    height = 1
  }

  filter {
        property = "datacenter"
        values   = ["dc1"]
        apply_if_exist = true
    } 
#Add the permissions block to your dashboard.
    permissions {
    acl {
      principal_id    = "F6BbjBWA4AE"
      principal_type  = "USER"
      actions         = ["WRITE"]
    }
  
  }

} 


 #Lab 3e

 #Task 8: ADDING ADDITIONAL CHARTS TO OVERVIEW DASHBOARD
#ADD THIS CODE TO YOUR main.tf TO THE OVERVIEW DASHBOARD RESOURCE
  chart {
    chart_id = signalfx_list_chart.tfchart_08.id
    width    = 3
    height   = 1
    column = 0
    row=2
  }
  chart {
    chart_id = signalfx_list_chart.tfchart_09.id
    column = 0
    width    = 3
    height   = 1
    row=3
  }
}

#Task 9: CREATE DATALINK RESOURCE
resource "signalfx_data_link" "dlink0" {
  property_name  = "dem_service"
  context_dashboard_id=signalfx_dashboard.db02.id

  target_signalfx_dashboard {
    is_default         = true
    name               = "XXX_overview"
    dashboard_group_id = signalfx_dashboard_group.dbg0.id
    dashboard_id       = signalfx_dashboard.db01.id
  }
}


resource "signalfx_dashboard" "db_import" {
  charts_resolution = "default"
  dashboard_group = "DASHBOARD GROUP ID"
  name = "XXX_Workspace"
    

    chart {
        chart_id = "CHART ID"
        column   = 0
        height   = 1
        row      = 0
        width    = 6
    }

    permissions {
        parent = "ID of the dashboard group"  
    }  /*ID of the dashboard group you want your dashboard to inherit permissions from*/
}