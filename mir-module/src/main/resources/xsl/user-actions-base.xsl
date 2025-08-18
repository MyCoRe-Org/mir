<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:const="xalan://org.mycore.user2.MCRUser2Constants"
                exclude-result-prefixes="xsl xalan i18n acl const">

  <xsl:import href="xslImport:userProfileActionsBase:user-actions-base.xsl"/>

  <xsl:param name="CurrentUser"/>
  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:template match="user" mode="actions">
    <xsl:variable name="isCurrentUser" select="$CurrentUser = $uid"/>

    <xsl:if test="(string-length($step) = 0) or ($step = 'changedPassword')">
      <xsl:variable name="isUserAdmin" select="acl:checkPermission(const:getUserAdminPermission())"/>
      <xsl:choose>
        <xsl:when test="$isUserAdmin">
          <a class="btn btn-secondary"
             href="{$WebApplicationBaseURL}authorization/change-user.xed?action=save&amp;id={$uid}">
            <xsl:value-of select="i18n:translate('component.user2.admin.changedata')"/>
          </a>
        </xsl:when>
        <xsl:when test="not($isCurrentUser)">
          <a class="btn btn-secondary"
             href="{$WebApplicationBaseURL}authorization/change-read-user.xed?action=save&amp;id={$uid}">
            <xsl:value-of select="i18n:translate('component.user2.admin.changedata')"/>
          </a>
        </xsl:when>
        <xsl:when test="$isCurrentUser and not(/user/@locked = 'true')">
          <a class="btn btn-secondary"
             href="{$WebApplicationBaseURL}authorization/change-current-user.xed?action=saveCurrentUser">
            <xsl:value-of select="i18n:translate('component.user2.admin.changedata')"/>
          </a>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="/user/@realm = 'local' and (not($isCurrentUser) or not(/user/@locked = 'true'))">
        <xsl:choose>
          <xsl:when test="$isCurrentUser">
            <a class="btn btn-secondary"
               href="{$WebApplicationBaseURL}authorization/change-password.xed?action=password">
              <xsl:value-of select="i18n:translate('component.user2.admin.changepw')"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a class="btn btn-secondary"
               href="{$WebApplicationBaseURL}authorization/change-password.xed?action=password&amp;id={$uid}">
              <xsl:value-of select="i18n:translate('component.user2.admin.changepw')"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$isUserAdmin and not($isCurrentUser)">
        <a class="btn btn-danger"
           href="{$ServletsBaseURL}MCRUserServlet?action=show&amp;id={$uid}&amp;XSL.step=confirmDelete">
          <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteYes')"/>
        </a>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
