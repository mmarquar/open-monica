// **********************************************************************
//
// Copyright (c) 2003-2013 ZeroC, Inc. All rights reserved.
//
// This copy of Ice is licensed to you under the terms described in the
// ICE_LICENSE file included in this distribution.
//
// **********************************************************************
//
// Ice version 3.5.0
//
// <auto-generated>
//
// Generated from file `MoniCA.ice'
//
// Warning: do not edit this file.
//
// </auto-generated>
//

package atnf.atoms.mon.comms;

public final class PubSubClientPrxHelper extends Ice.ObjectPrxHelperBase implements PubSubClientPrx
{
    private static final String __updateData_name = "updateData";

    public void updateData(PointDataIce[] newdata)
    {
        updateData(newdata, null, false);
    }

    public void updateData(PointDataIce[] newdata, java.util.Map<String, String> __ctx)
    {
        updateData(newdata, __ctx, true);
    }

    private void updateData(PointDataIce[] newdata, java.util.Map<String, String> __ctx, boolean __explicitCtx)
    {
        if(__explicitCtx && __ctx == null)
        {
            __ctx = _emptyContext;
        }
        final Ice.Instrumentation.InvocationObserver __observer = IceInternal.ObserverHelper.get(this, "updateData", __ctx);
        int __cnt = 0;
        try
        {
            while(true)
            {
                Ice._ObjectDel __delBase = null;
                try
                {
                    __delBase = __getDelegate(false);
                    _PubSubClientDel __del = (_PubSubClientDel)__delBase;
                    __del.updateData(newdata, __ctx, __observer);
                    return;
                }
                catch(IceInternal.LocalExceptionWrapper __ex)
                {
                    __handleExceptionWrapper(__delBase, __ex, __observer);
                }
                catch(Ice.LocalException __ex)
                {
                    __cnt = __handleException(__delBase, __ex, null, __cnt, __observer);
                }
            }
        }
        finally
        {
            if(__observer != null)
            {
                __observer.detach();
            }
        }
    }

    public Ice.AsyncResult begin_updateData(PointDataIce[] newdata)
    {
        return begin_updateData(newdata, null, false, null);
    }

    public Ice.AsyncResult begin_updateData(PointDataIce[] newdata, java.util.Map<String, String> __ctx)
    {
        return begin_updateData(newdata, __ctx, true, null);
    }

    public Ice.AsyncResult begin_updateData(PointDataIce[] newdata, Ice.Callback __cb)
    {
        return begin_updateData(newdata, null, false, __cb);
    }

    public Ice.AsyncResult begin_updateData(PointDataIce[] newdata, java.util.Map<String, String> __ctx, Ice.Callback __cb)
    {
        return begin_updateData(newdata, __ctx, true, __cb);
    }

    public Ice.AsyncResult begin_updateData(PointDataIce[] newdata, Callback_PubSubClient_updateData __cb)
    {
        return begin_updateData(newdata, null, false, __cb);
    }

    public Ice.AsyncResult begin_updateData(PointDataIce[] newdata, java.util.Map<String, String> __ctx, Callback_PubSubClient_updateData __cb)
    {
        return begin_updateData(newdata, __ctx, true, __cb);
    }

    private Ice.AsyncResult begin_updateData(PointDataIce[] newdata, java.util.Map<String, String> __ctx, boolean __explicitCtx, IceInternal.CallbackBase __cb)
    {
        IceInternal.OutgoingAsync __result = new IceInternal.OutgoingAsync(this, __updateData_name, __cb);
        try
        {
            __result.__prepare(__updateData_name, Ice.OperationMode.Normal, __ctx, __explicitCtx);
            IceInternal.BasicStream __os = __result.__startWriteParams(Ice.FormatType.DefaultFormat);
            pointdatasetHelper.write(__os, newdata);
            __os.writePendingObjects();
            __result.__endWriteParams();
            __result.__send(true);
        }
        catch(Ice.LocalException __ex)
        {
            __result.__exceptionAsync(__ex);
        }
        return __result;
    }

    public void end_updateData(Ice.AsyncResult __result)
    {
        __end(__result, __updateData_name);
    }

    public static PubSubClientPrx checkedCast(Ice.ObjectPrx __obj)
    {
        PubSubClientPrx __d = null;
        if(__obj != null)
        {
            if(__obj instanceof PubSubClientPrx)
            {
                __d = (PubSubClientPrx)__obj;
            }
            else
            {
                if(__obj.ice_isA(ice_staticId()))
                {
                    PubSubClientPrxHelper __h = new PubSubClientPrxHelper();
                    __h.__copyFrom(__obj);
                    __d = __h;
                }
            }
        }
        return __d;
    }

    public static PubSubClientPrx checkedCast(Ice.ObjectPrx __obj, java.util.Map<String, String> __ctx)
    {
        PubSubClientPrx __d = null;
        if(__obj != null)
        {
            if(__obj instanceof PubSubClientPrx)
            {
                __d = (PubSubClientPrx)__obj;
            }
            else
            {
                if(__obj.ice_isA(ice_staticId(), __ctx))
                {
                    PubSubClientPrxHelper __h = new PubSubClientPrxHelper();
                    __h.__copyFrom(__obj);
                    __d = __h;
                }
            }
        }
        return __d;
    }

    public static PubSubClientPrx checkedCast(Ice.ObjectPrx __obj, String __facet)
    {
        PubSubClientPrx __d = null;
        if(__obj != null)
        {
            Ice.ObjectPrx __bb = __obj.ice_facet(__facet);
            try
            {
                if(__bb.ice_isA(ice_staticId()))
                {
                    PubSubClientPrxHelper __h = new PubSubClientPrxHelper();
                    __h.__copyFrom(__bb);
                    __d = __h;
                }
            }
            catch(Ice.FacetNotExistException ex)
            {
            }
        }
        return __d;
    }

    public static PubSubClientPrx checkedCast(Ice.ObjectPrx __obj, String __facet, java.util.Map<String, String> __ctx)
    {
        PubSubClientPrx __d = null;
        if(__obj != null)
        {
            Ice.ObjectPrx __bb = __obj.ice_facet(__facet);
            try
            {
                if(__bb.ice_isA(ice_staticId(), __ctx))
                {
                    PubSubClientPrxHelper __h = new PubSubClientPrxHelper();
                    __h.__copyFrom(__bb);
                    __d = __h;
                }
            }
            catch(Ice.FacetNotExistException ex)
            {
            }
        }
        return __d;
    }

    public static PubSubClientPrx uncheckedCast(Ice.ObjectPrx __obj)
    {
        PubSubClientPrx __d = null;
        if(__obj != null)
        {
            if(__obj instanceof PubSubClientPrx)
            {
                __d = (PubSubClientPrx)__obj;
            }
            else
            {
                PubSubClientPrxHelper __h = new PubSubClientPrxHelper();
                __h.__copyFrom(__obj);
                __d = __h;
            }
        }
        return __d;
    }

    public static PubSubClientPrx uncheckedCast(Ice.ObjectPrx __obj, String __facet)
    {
        PubSubClientPrx __d = null;
        if(__obj != null)
        {
            Ice.ObjectPrx __bb = __obj.ice_facet(__facet);
            PubSubClientPrxHelper __h = new PubSubClientPrxHelper();
            __h.__copyFrom(__bb);
            __d = __h;
        }
        return __d;
    }

    public static final String[] __ids =
    {
        "::Ice::Object",
        "::atnf::atoms::mon::comms::PubSubClient"
    };

    public static String ice_staticId()
    {
        return __ids[1];
    }

    protected Ice._ObjectDelM __createDelegateM()
    {
        return new _PubSubClientDelM();
    }

    protected Ice._ObjectDelD __createDelegateD()
    {
        return new _PubSubClientDelD();
    }

    public static void __write(IceInternal.BasicStream __os, PubSubClientPrx v)
    {
        __os.writeProxy(v);
    }

    public static PubSubClientPrx __read(IceInternal.BasicStream __is)
    {
        Ice.ObjectPrx proxy = __is.readProxy();
        if(proxy != null)
        {
            PubSubClientPrxHelper result = new PubSubClientPrxHelper();
            result.__copyFrom(proxy);
            return result;
        }
        return null;
    }

    public static final long serialVersionUID = 0L;
}
