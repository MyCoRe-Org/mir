<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:userProfileActionsBase:user-actions-base.xsl"/>

  <xsl:param name="CurrentUser"/>
  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:template match="user" mode="actions">
    <xsl:variable name="isCurrentUser" select="$CurrentUser = $uid"/>

    <xsl:if test="(string-length($step) = 0) or ($step = 'changedPassword')">
      <xsl:variable name="isUserAdmin" select="document('checkPermission:POOLPRIVILEGE:administrate-users')/boolean = 'true'"/>

      <xsl:choose>
        <xsl:when test="$isUserAdmin">
          <a class="btn btn-secondary"
             href="{$WebApplicationBaseURL}authorization/change-user.xed?action=save&amp;id={$uid}">
            <xsl:value-of select="document('i18n:component.user2.admin.changedata')/i18n/text()"/>
          </a>
        </xsl:when>
        <xsl:when test="not($isCurrentUser)">
          <a class="btn btn-secondary"
             href="{$WebApplicationBaseURL}authorization/change-read-user.xed?action=save&amp;id={$uid}">
            <xsl:value-of select="document('i18n:component.user2.admin.changedata')/i18n/text()"/>
          </a>
        </xsl:when>
        <xsl:when test="$isCurrentUser and not(/user/@locked = 'true')">
          <a class="btn btn-secondary"
             href="{$WebApplicationBaseURL}authorization/change-current-user.xed?action=saveCurrentUser">
            <xsl:value-of select="document('i18n:component.user2.admin.changedata')/i18n/text()"/>
          </a>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="/user/@realm = 'local' and (not($isCurrentUser) or not(/user/@locked = 'true'))">
        <xsl:choose>
          <xsl:when test="$isCurrentUser">
            <a class="btn btn-secondary"
               href="{$WebApplicationBaseURL}authorization/change-password.xed?action=password">
              <xsl:value-of select="document('i18n:component.user2.admin.changepw')/i18n/text()"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a class="btn btn-secondary"
               href="{$WebApplicationBaseURL}authorization/change-password.xed?action=password&amp;id={$uid}">
              <xsl:value-of select="document('i18n:component.user2.admin.changepw')/i18n/text()"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$isUserAdmin and not($isCurrentUser)">
        <a class="btn btn-danger"
           href="{$ServletsBaseURL}MCRUserServlet?action=show&amp;id={$uid}&amp;XSL.step=confirmDelete">
          <xsl:value-of select="document('i18n:component.user2.admin.userDeleteYes')/i18n/text()"/>
        </a>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
