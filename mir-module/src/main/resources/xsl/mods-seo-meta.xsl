<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="xsl mcrxml mods xlink xalan">

    <xsl:include href="mods-utils.xsl"/>

    <xsl:param name="CurrentLang" />

    <xsl:template match="mods:mods" mode="seo-meta">
        <!-- meta title -->
        <xsl:choose>
            <xsl:when test="mods:titleInfo[@xml:lang = $CurrentLang]">
                <xsl:apply-templates select="mods:titleInfo[@xml:lang = $CurrentLang]" mode="seo"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="mods:titleInfo[1]" mode="seo"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- meta description -->
        <xsl:choose>
            <xsl:when test="mods:abstract[@xml:lang = $CurrentLang]">
                <xsl:apply-templates select="mods:abstract[@xml:lang = $CurrentLang]|mods:abstract[@xml:lang = $CurrentLang]/@xlink:href" mode="seo"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="mods:abstract[1]|mods:abstract[1]/@xlink:href" mode="seo"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="mods:titleInfo" mode="seo">
        <meta>
            <xsl:attribute name="name">title</xsl:attribute>
            <xsl:attribute name="content">
                <xsl:choose>
                    <!-- SEO titles are limited to about 70 characters, ideally it should be between 55 and 65 characters -->
                    <xsl:when test="string-length(mods:title)>60">
                        <xsl:value-of select="mcrxml:shortenText(mods:title,60)" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="mods:title" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </meta>

    </xsl:template>

    <xsl:template match="mods:abstract[not(@altFormat)] | mods:tableOfContents[not(@altFormat)]" mode="seo">
        <meta>
            <xsl:attribute name="name">description</xsl:attribute>
            <xsl:attribute name="content">
                <xsl:choose>
                    <!-- SEO descriptions are limited to about 155 characters for desktop search and 120 characters for mobile search. -->
                    <xsl:when test="string-length(.)>140">
                        <xsl:value-of select="mcrxml:shortenText(.,140)" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </meta>
    </xsl:template>

    <!-- suppress all else:-->
    <xsl:template match="*" mode="seo"/>

</xsl:stylesheet>
