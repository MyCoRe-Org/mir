<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    xmlns:str="http://exslt.org/strings"
    exclude-result-prefixes="i18n mcrxsl str"
    >
    
    <xsl:param name="MIR.OwnerStrategy.AllowedRolesForSearch" select="'admin,editor'" />
    
    <xsl:variable name="isSearchAllowedForCurrentUser">
        <xsl:for-each select="str:tokenize($MIR.OwnerStrategy.AllowedRolesForSearch,',')">
            <xsl:if test="mcrxsl:isCurrentUserInRole(.)">
                <xsl:text>true</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="owner">
        <xsl:choose>
            <xsl:when test="contains($isSearchAllowedForCurrentUser, 'true')">
                <xsl:text>*</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$CurrentUser" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

</xsl:stylesheet>