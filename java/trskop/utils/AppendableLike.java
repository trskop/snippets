package trskop.utils;

import java.io.IOException;

import trskop.IAppendTo;


/**
 *
 * @author Peter Trsko
 */
public class AppendableLike implements Appendable
{
    private static enum Type
    {
        STRING_BUFFER,
        STRING_BUILDER,
        OTHER;
    }

    private Appendable _buff = null;
    private Type _type = Type.OTHER;

    public AppendableLike(Appendable buff)
    {
        _buff = buff;

        if (buff instanceof StringBuilder)
        {
            _type = Type.STRING_BUILDER;
        }
        else if (buff instanceof StringBuffer)
        {
            _type = Type.STRING_BUFFER;
        }
        else
        {
            _type = Type.OTHER;
        }
    }

    private <T extends Appendable> T impl(Class<T> clazz)
    {
        if (!clazz.isInstance(_buff))
        {
            throw new IllegalStateException(
                "Attribute _buff is not of expected type.");
        }

        return clazz.cast(_buff);
    }

    public AppendableLike append(IAppendTo obj) throws IOException
    {
        if (obj == null)
        {
            _buff.append("null");
        }
        else
        {
            obj.appendTo(_buff);
        }

        return this;
    }

    // {{{ Appendable interface implementation ////////////////////////////////

    public AppendableLike append(CharSequence csq, int start, int end)
        throws IOException
    {
        _buff.append(csq);

        return this;
    }

    public AppendableLike append(CharSequence csq) throws IOException
    {
        _buff.append(csq);

        return this;
    }

    public AppendableLike append(char c) throws IOException
    {
        _buff.append(c);

        return this;
    }

    // }}} Appendable interface implementation ////////////////////////////////

    // {{{ Interface similar to StringBuffer/StringBuilder ////////////////////

    public AppendableLike append(boolean b)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(b);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(b);
                break;
            default:
                _buff.append(Boolean.toString(b));
        }

        return this;
    }

    public AppendableLike append(char[] str)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(str);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(str);
                break;
            default:
                _buff.append(new String(str));
        }

        return this;
    }

    public AppendableLike append(char[] str, int offset, int len)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(str, offset, len);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(str, offset, len);
                break;
            default:
                _buff.append(new String(str, offset, len));
        }

        return this;
    }

    public AppendableLike append(double d)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(d);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(d);
                break;
            default:
                _buff.append(Double.toString(d));
        }

        return this;
    }

    public AppendableLike append(float f)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(f);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(f);
                break;
            default:
                _buff.append(Float.toString(f));
        }

        return this;
    }

    public AppendableLike append(int i)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(i);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(i);
                break;
            default:
                _buff.append(Integer.toString(i));
        }

        return this;
    }

    public AppendableLike append(long l)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(l);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(l);
                break;
            default:
                _buff.append(Long.toString(l));
        }

        return this;
    }

    public AppendableLike append(Object obj)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(obj);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(obj);
                break;
            default:
                _buff.append(obj.toString());
        }

        return this;
    }

    public AppendableLike append(String str)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(str);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(str);
                break;
            default:
                _buff.append(str);
        }

        return this;
    }

    public AppendableLike append(StringBuffer sb)
        throws IOException
    {
        switch (_type)
        {
            case STRING_BUILDER:
                impl(StringBuilder.class).append(sb);
                break;
            case STRING_BUFFER:
                impl(StringBuffer.class).append(sb);
                break;
            default:
                _buff.append(sb.toString());
        }

        return this;
    }

    // }}} Interface similar to StringBuffer/StringBuilder ////////////////////
}
