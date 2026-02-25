/**
 * Provides classes relevant for IRP.
 */

module IRP {
  private import cpp as CPP
  private import semmle.code.cpp.dataflow.new.DataFlow::DataFlow as DataFlow
  private import semmle.code.cpp.controlflow.DefinitionsAndUses as DefUse

  /** An `IRP` parameter. */
  class Parameter extends CPP::Parameter {
    Parameter() {
      exists(CPP::PointerType pt |
        pt = this.getType().getUnspecifiedType() and
        pt.getBaseType().(CPP::Struct).hasName("_IRP")
      )
    }

    /** Gets a use of this `IRP` parameter. */
    CPP::VariableAccess getAUse() {
      DefUse::parameterUsePair(this, result)
    }

    private DeviceIoControlAccess getADeviceIoControlAccess() {
      this = result.getParameter()
    }

    private CPP::FieldAccess getADeviceIoControlQualifiedAccess() {
      getASource(result.getQualifier()) = this.getADeviceIoControlAccess()
    }

    /**
     * Gets an access to the input buffer length of this `IRP` parameter, for
     * example
     *
     * ```
     * Stack = IoGetCurrentIrpStackLocation(Irp);
     * ... Stack->Parameters.DeviceIoControl.InputBufferLength ...
     * ```
     */
    CPP::FieldAccess getAnInputBufferLengthAccess() {
      result = this.getADeviceIoControlQualifiedAccess()
      and result.getTarget().hasName("InputBufferLength")
    }

    /**
     * Gets an access to the output buffer length of this `IRP` parameter, for
     * example
     *
     * ```
     * Stack = IoGetCurrentIrpStackLocation(Irp);
     * ... Stack->Parameters.DeviceIoControl.OutputBufferLength ...
     * ```
     */
    CPP::FieldAccess getAnOutputBufferLengthAccess() {
      result = this.getADeviceIoControlQualifiedAccess()
      and result.getTarget().hasName("OutputBufferLength")
    }
  }

  /**
   * A field access using an `IRP` parameter.
   */
  abstract class FieldAccess extends CPP::FieldAccess {
    /** Gets the `IRP` parameter belonging to this access. */
    abstract Parameter getParameter();
  }

  /** Gets a possible source for expression `e`. */
  private CPP::Expr getASource(CPP::Expr e) {
    DataFlow::localFlow(DataFlow::exprNode(result), DataFlow::exprNode(e))
  }

  /**
   * An access to an `IRP` user buffer, for example
   *
   * ```
   * p->UserBuffer
   * ```
   */
  class UserBufferAccess extends FieldAccess {
    UserBufferAccess() {
      userBufferAcces(_, this)
    }

    override Parameter getParameter() {
      userBufferAcces(result, this)
    }
  }

  private predicate userBufferAcces(Parameter p, CPP::FieldAccess fa) {
    p.getAUse() = fa.getQualifier() and
    fa.getTarget().hasName("UserBuffer")
  }

  /**
   * A call to `IoGetCurrentIrpStackLocation()`.
   */
  class IoGetCurrentIrpStackLocationCall extends CPP::FunctionCall {
    IoGetCurrentIrpStackLocationCall() {
      ioGetCurrentIrpStackLocationCall(_, this)
    }

    Parameter getParameter() {
      ioGetCurrentIrpStackLocationCall(result, this)
    }
  }

  private predicate ioGetCurrentIrpStackLocationCall(Parameter p, CPP::FunctionCall fc) {
    fc.getAnArgument() = p.getAnAccess() and
    fc.getTarget().hasName("IoGetCurrentIrpStackLocation")
  }

  /**
   * An access to an `IRP` device IO control, for example
   *
   * ```
   * IrpStack = IoGetCurrentIrpStackLocation(Irp);
   * ... IrpStack->Parameters.DeviceIoControl ...
   * ```
   */
  class DeviceIoControlAccess extends FieldAccess {
    DeviceIoControlAccess() {
      deviceIoControlAccess(_, this)
    }

    override Parameter getParameter() {
      deviceIoControlAccess(result, this)
    }
  }

  private predicate deviceIoControlAccess(Parameter p, CPP::FieldAccess fa) {
    exists(IoGetCurrentIrpStackLocationCall fc, CPP::FieldAccess fa1 |
      fc.getParameter() = p and
      getASource(fa1.getQualifier()) = fc and
      fa1.getTarget().hasName("Parameters") and
      getASource(fa.getQualifier()) = fa1 and
      fa.getTarget().hasName("DeviceIoControl")
    )
  }

  /**
   * An access to an `IRP` system buffer, for example
   *
   * ```
   * Irp->AssociatedIrp.SystemBuffer
   * ```
   */
  class SystemBufferAccess extends FieldAccess {
    SystemBufferAccess() {
      systemBufferAccess(_, this)
    }

    override Parameter getParameter() {
      systemBufferAccess(result, this)
    }
  }

  private predicate systemBufferAccess(Parameter p, CPP::FieldAccess fa) {
    exists(CPP::FieldAccess qual |
      p.getAUse() = qual.getQualifier() and
      qual.getTarget().hasName("AssociatedIrp") and
      fa.getQualifier() = getASource(qual) and
      fa.getTarget().hasName("SystemBuffer")
    )
  }

  /**
   * An access to an `IRP` type 3 input buffer, for example
   *
   * ```
   * IrpStack = IoGetCurrentIrpStackLocation(Irp);
   * ... IrpStack->Parameters.DeviceIoControl.Type3InputBuffer ...
   * ```
   */
  class Type3InputBufferAccess extends FieldAccess {
    Type3InputBufferAccess() {
      exists(DeviceIoControlAccess a |
        getASource(this.getQualifier()) = a and
        this.getTarget().hasName("Type3InputBuffer")
      )
    }

    override Parameter getParameter() {
      deviceIoControlAccess(result, this.getQualifier())
    }
  }
  
  /**
   * An access to the input buffer length of an `IRP` device IO control, for example
   *
   * ```
   * IrpStack = IoGetCurrentIrpStackLocation(Irp);
   * ... IrpStack->Parameters.DeviceIoControl.InputBufferLength ...
   * ```
   */
  class InputBufferLengthAccess extends FieldAccess {
    private Parameter parameter;
    InputBufferLengthAccess() {
      this = parameter.getAnInputBufferLengthAccess()
    }

    override Parameter getParameter() {
      result = parameter
    }
  }

  /**
   * An access to the output buffer length of an `IRP` device IO control, for example
   *
   * ```
   * IrpStack = IoGetCurrentIrpStackLocation(Irp);
   * ... IrpStack->Parameters.DeviceIoControl.OutputBufferLength ...
   * ```
   */
  class OutputBufferLengthAccess extends FieldAccess {
    private Parameter parameter;
    OutputBufferLengthAccess() {
      this = parameter.getAnOutputBufferLengthAccess()
    }

    override Parameter getParameter() {
      result = parameter
    }
  }
}
