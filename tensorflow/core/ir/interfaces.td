/* Copyright 2021 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#ifndef TFG_INTERFACES
#define TFG_INTERFACES

include "mlir/IR/OpBase.td"

def ControlArgumentInterface : OpInterface<"ControlArgumentInterface"> {
  let description = [{
    Operations with regions may organize their control token arguments and data
    arguments differently. For example, `tfg.func` has pairs of data and control
    token arguments.

    This interface allows these operations to define specific functions for
    getting a data or control argument, given one or the other.
  }];
  let cppNamespace = "::mlir::tfg";

  let methods = [
    StaticInterfaceMethod<[{
        Given a block argument that is a control token, return the associated
        data argument.
      }],
      "mlir::BlockArgument", "getDataValueOf", (ins "BlockArgument":$ctl)
    >,
    StaticInterfaceMethod<[{
        Given a block argument that is a data value, return the associated
        control token.
      }],
      "mlir::BlockArgument", "getControlTokenOf", (ins "BlockArgument":$data)
    >,
    StaticInterfaceMethod<[{
        Get the data value corresponding to a given argument index.
      }],
      "mlir::BlockArgument", "getDataValue", (ins "Region &":$region,
                                                  "unsigned":$idx)
    >,
    StaticInterfaceMethod<[{
        Get the control token corresponding to a given argument index.
      }],
      "mlir::BlockArgument", "getControlToken", (ins "Region &":$region,
                                                     "unsigned":$idx), [{}],
      [{
        mlir::BlockArgument data = ConcreteOp::getDataValue(region, idx);
        return ConcreteOp::getControlTokenOf(data);
      }]
    >,
  ];

  let verify = [{
    for (Region &region : $_op->getRegions())
      if (failed(ControlArgumentInterface::verifyRegion($_op, region)))
        return failure();
    return success();
  }];

  let extraClassDeclaration = [{
    /// Verify that a region has the same number of data and control arguments.
    static LogicalResult verifyRegion(Operation *op, Region &region);
  }];
}

#endif // TFG_INTERFACES
