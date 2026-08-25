<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template name="user-info-row">
    <xsl:param name="userid" as="xs:string?" />
    <xsl:param name="label-key" select="'mir.metaData.detailBox.by'" as="xs:string" />

    <xsl:variable name="user" select="if ($userid) then document('notnull:user:' || $userid)/user else ()" />
    <xsl:variable name="userid-with-realm" select="$user/@name || '@' || $user/@realm" />

    <xsl:call-template name="meta-row">
      <xsl:with-param name="label-key" select="$label-key" />
      <xsl:with-param name="value-title" select="
        if (string-length($user/realName) &gt; 0) then $userid-with-realm else ()
      " />
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="not($user)">
            <span class="not_found">
              <xsl:value-of select="$userid" />
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="display-name" select="
              if (string-length($user/realName) &gt; 0
                and mcrproperty:get('MIR.AdmindataBox.ShowRealUserName') = 'true')
              then string($user/realName)
              else string($user/@name)
            " />
            <xsl:choose>
              <xsl:when test="mcracl:check-permission('POOLPRIVILEGE', 'administrate-users')">
                <a href="{$WebApplicationBaseURL}servlets/MCRUserServlet?action=show&amp;id={encode-for-uri($userid-with-realm)}">
                  <xsl:value-of select="$display-name" />
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$display-name" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
