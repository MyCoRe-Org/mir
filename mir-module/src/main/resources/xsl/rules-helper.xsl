<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~  This file is part of ***  M y C o R e  ***
  ~  See http://www.mycore.de/ for details.
  ~
  ~  MyCoRe is free software: you can redistribute it and/or modify
  ~  it under the terms of the GNU General Public License as published by
  ~  the Free Software Foundation, either version 3 of the License, or
  ~  (at your option) any later version.
  ~
  ~  MyCoRe is distributed in the hope that it will be useful,
  ~  but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~  GNU General Public License for more details.
  ~
  ~  You should have received a copy of the GNU General Public License
  ~  along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:rh="https://mycore.org/rule-helper"
                version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="rh:include">
        <xsl:choose>
            <xsl:when test="@href">
                <xsl:comment>Included file: <xsl:value-of select="@href" /></xsl:comment>
                <xsl:choose>
                    <xsl:when test="@rule-helper='false'">
                        <xsl:copy-of select="document(@href)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="document(@href)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">href missing in rh:include</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="rh:each-property">
        <xsl:variable name="propertyName" select="@property"/>
        <xsl:variable name="separator">
            <xsl:choose>
                <xsl:when test="@separator">
                    <xsl:value-of select="@separator"/>
                </xsl:when>
                <xsl:otherwise>,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="property" select="document(concat('property:', $propertyName))/entry/text()"/>
        <xsl:variable name="properties" select="fn:tokenize($property, $separator)"/>

        <xsl:variable name="content">
            <xsl:copy-of select="*"/>
        </xsl:variable>

        <xsl:variable name="transformedContent">
            <xsl:for-each select="$properties">
                <xsl:variable name="propVal" select="."/>
                <xsl:apply-templates select="$content" mode="replaceProperty">
                    <xsl:with-param name="value" select="$propVal"/>
                    <xsl:with-param name="name" select="$propertyName"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:variable>

        <xsl:apply-templates select="$transformedContent" />
    </xsl:template>

    <xsl:template match="node()|@*" mode="replaceProperty">
    <xsl:param name="value"/>
    <xsl:param name="name"/>
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="replaceProperty">
                <xsl:with-param name="value" select="$value" />
                <xsl:with-param name="name" select="$name" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="rh:each-property-replace" mode="replaceProperty">
        <xsl:param name="value"/>
        <xsl:param name="name"/>

        <xsl:choose>
            <xsl:when test="$name = @property">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>