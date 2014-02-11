package pkg.name;


public class ClassName
{
    // {{{ Constructors ///////////////////////////////////////////////////////

    /**
     * TODO: Javadoc.
     */
    public ClassName()
    {
        // Empty implementation.
    }

    // }}} Constructors ///////////////////////////////////////////////////////

    // {{{ Overriding equals and hashCode /////////////////////////////////////

    /**
     * Compare this object with other one for equivalence.
     *
     * @param obj
     *   The reference object with which to compare.
     * @return
     *   <code>true</code> if this object is the same as specified obj argument
     *   or <code>false</code> otherwise.
     */
    @Override
    public boolean equals(Object obj)
    {
        if (this == obj)
        {
            return true;
        }

        if (obj instanceof ClassName)
        {
            // TODO

            return true;
        }

        return false;
    }

    /**
     * Returns a hash code for this object.
     *
     * @return
     *   A hash code value for this object.
     */
    @Override
    public int hashCode()
    {
        int hash = 42;

        // TODO

        return hash;
    }

    // }}} Overriding equals and hashCode /////////////////////////////////////
}
