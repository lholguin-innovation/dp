using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Security.Principal;

/// <summary>
/// Summary description for Global
/// </summary>
public class Global
{
    void Application_AuthenticateRequest(Object sender, EventArgs e)
    {
        String cookieName = FormsAuthentication.FormsCookieName;
        HttpCookie authCookie = new HttpCookie(cookieName);

        if (null == authCookie)
        {//There is no authentication cookie.
            return;
        }

        FormsAuthenticationTicket authTicket = null;

        try
        {
            authTicket = FormsAuthentication.Decrypt(authCookie.Value);
        }
        catch (Exception ex)
        {
            //Write the exception to the Event Log.
            return;
        }

        if (null == authTicket)
        {//Cookie failed to decrypt.
            return;
        }

        //When the ticket was created, the UserData property was assigned a
        //pipe-delimited string of group names.
        String[] groups = authTicket.UserData.Split(new char[] { '|' });

        //Create an Identity.
        GenericIdentity id = new GenericIdentity(authTicket.Name, "LdapAuthentication");

        //This principal flows throughout the request.
        GenericPrincipal principal = new GenericPrincipal(id, groups);

        HttpContext.Current.User = principal;
    }
}