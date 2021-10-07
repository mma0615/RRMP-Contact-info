global class flowPlugIn implements Process.Plugin {
    
    global Process.PluginResult invoke(Process.PluginRequest request) { 
        String inputFromFlow = (String) request.inputParameters.get('inputFromFlow');
        Map<String,Object> result = new Map<String,Object>();
        //Your logic here for preparing output variables.
        result.put('outputFromApex', 'I am returned from Apex Class');
        return new Process.PluginResult(result);
     }
  
     global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'Sample inout output demo for apex and flow';
        result.Tag = 'FlowPlugin Class';
        result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
              new Process.PluginDescribeResult.InputParameter('inputFromFlow', 
              Process.PluginDescribeResult.ParameterType.STRING, true) 
           }; 
        result.outputParameters = new 
           List<Process.PluginDescribeResult.OutputParameter>{              
              new Process.PluginDescribeResult.OutputParameter('outputFromApex', 
              Process.PluginDescribeResult.ParameterType.STRING)
                  }; 
        return result; 
     }
}
