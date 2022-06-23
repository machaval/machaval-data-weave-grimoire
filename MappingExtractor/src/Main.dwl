%dw 2.0
output application/json

input payload: Node application/json

type Node = {
  class: String,
  value?: String,
  children?: Array<Node>
}

type Source = 
{
  kind: "Selection",
  expression: Array<String>
} | {
  kind: "Map",
  expression: Array<String>,
  mapping: Source
} | {
  kind: "Literal", 
  value: String
} | {
  kind: "Unknown"
} | {
  kind: "Concat",
  left: Source,
  right: Source
} | {
  kind: "Object",
  fields: {
    _: {
      source: Source,
      conditional: Boolean
    }
  }
}

fun extractName(kvp: Node) =    
  kvp.children[0].value

fun extractItemName(function: Node) = do {
    function  match {
      case is {"class": "FunctionNode"} -> function.children[0].children[0].children[0].value
      else -> "\$" //case of annonimous function
    }
  }
  
fun extractSource(node: Node) = do { 
    node match {
      case value is {class: "NullSafeNode"} -> extractSource(node.children[0]!)
      case value if value is {class: "BinaryOpNode", "value": "ValueSelectorOpId\$"} -> do {
          var leftSource = extractSource(node.children[0])
          var sourceFieldName = node.children[1].children[0].value default ""
          ---
          {
            kind: "Selection",   
            expression: (leftSource.expression default [] ) ++ [ sourceFieldName ]
          }          
        }
      case value is {class: "VariableReferenceNode"} ->  
        {
          kind: "Selection",   
          expression: [ node.children[0].value! ]
        }  
      case on is {class: "ObjectNode"} -> {
          kind: "Object",
          fields: (
            node.children map ((field) ->    
                  field match {
                    case kvp is {class: "KeyValuePairNode"} -> 
                      {
                        (extractName(kvp.children[0])): {                                                   
                            source: extractSource(kvp.children[1]),
                            conditional: kvp.children[2]?
                          }
                      }
                    else -> null  
                  })
          )     
        }
      case on is {class: "FunctionNode"} -> extractSource(node.children[1])  
      case value is {class: "FunctionCallNode"} ->  
        node.children[0] match {
          case is {"class": "VariableReferenceNode"} -> do {
              var funcName = node.children[0].children[0].value
              var functionParams = node.children[1]
              ---
              funcName match {
                case "map" ->  do {                           	                   	
                    {
                      kind: "Map",   
                      expression: extractSource(functionParams.children[0]).expression default [],
                      itemName: extractItemName(functionParams.children[1]),
                      mapping: extractSource(functionParams.children[1])
                    }
                  }
                case "++" ->  do {                           	                   	
                    {
                      kind: "Concat",    
                      left: extractSource(functionParams.children[0]),                                                                 
                      right: extractSource(functionParams.children[1])                                                                 
                    }
                  } 
                case "filter" ->  do {                           	                   	
                    extractSource(functionParams.children[0])
                  }    
                case unary if(sizeOf(functionParams) == 1) -> extractSource(functionParams.children[0])
                else -> { kind: "Unknown" }   //TODO add more use cases
              }
            }
          else ->  { kind: "Unknown" }
        }
      case is {"class": "StringNode"} | {"class": "NumberNode"}| {"class": "BooleanNode"} -> 
        { kind: "Literal", value: node.value }     
      else -> { kind: "Unknown" }
    }
  }


---
extractSource(payload.children[1])