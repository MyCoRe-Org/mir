<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:str="http://exslt.org/strings"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcrxml str">

    <xsl:param name="MIR.OwnerStrategy.AllowedRolesForSearch" select="'admin,editor'" />

    <xsl:variable name="isSearchAllowedForCurrentUser">
        <xsl:for-each select="str:tokenize($MIR.OwnerStrategy.AllowedRolesForSearch,',')">
            <xsl:if test="mcrxml:isCurrentUserInRole(.)">
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

    <xsl:template name="iconLink">
        <xsl:param name="baseURL"/>
        <xsl:param name="mimeType"/>
        <xsl:param name="derivateMaindoc"/>

        <xsl:choose>
            <xsl:when test="$mimeType='application/pdf' or
                    $mimeType='application/vnd.ms-excel' or
                    $mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' or
                    $mimeType='application/ms-word' or
                    $mimeType='application/msword' or
                    $mimeType='application/vnd.openxmlformats-officedocument.wordprocessingml.document' or
                    $mimeType='application/vnd.openxmlformats-officedocument.presentationml.presentation' or
                    $mimeType='application/powerpoint' or
                    $mimeType='application/zip'">
                <xsl:variable name="fileType">
                    <xsl:choose>
                        <xsl:when test="$mimeType='application/pdf'">
                            <xsl:value-of select="'pdf'"/>
                        </xsl:when>
                        <xsl:when test="$mimeType='application/vnd.ms-excel'">
                            <xsl:value-of select="'msexcel'"/>
                        </xsl:when>
                        <xsl:when
                                test="$mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'">
                            <xsl:value-of select="'xlsx'"/>
                        </xsl:when>
                        <xsl:when test="$mimeType='application/ms-word' or $mimeType='application/msword'">
                            <xsl:value-of select="'msword97'"/>
                        </xsl:when>
                        <xsl:when
                                test="$mimeType='application/vnd.openxmlformats-officedocument.wordprocessingml.document'">
                            <xsl:value-of select="'docx'"/>
                        </xsl:when>
                        <xsl:when
                                test="$mimeType='application/vnd.openxmlformats-officedocument.presentationml.presentation'">
                            <xsl:value-of select="'pptx'"/>
                        </xsl:when>
                        <xsl:when test="$mimeType='application/powerpoint'">
                            <xsl:value-of select="'msppt'"/>
                        </xsl:when>
                        <xsl:when test="$mimeType='application/zip'">
                            <xsl:value-of select="'zip'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="concat($baseURL,'images/svg_icons/download_', $fileType,'.svg')"/>
            </xsl:when>
            <xsl:when
                    test="$mimeType='image/png' or
                            $mimeType='image/jpeg' or
                            $mimeType='image/tiff' or
                            $mimeType='image/gif' or
                            $mimeType='image/bmp' or
                            $mimeType='image/x-bmp' or
                            $mimeType='image/x-ms-bmp'">
                <xsl:value-of select="concat($baseURL,'images/svg_icons/download_image.svg')"/>
            </xsl:when>
            <xsl:when
                    test="$mimeType='audio/mpeg' or
                            $mimeType='audio/x-wav' or
                            $mimeType='audio/m4a' or
                            $mimeType='audio/x-ms-wma'">
                <xsl:value-of select="concat($baseURL,'images/svg_icons/download_audio.svg')"/>
            </xsl:when>
            <xsl:when
                    test="$mimeType='video/mp4' or
                            $mimeType='video/x-m4v' or
                            $mimeType='video/x-msvideo' or
                            $mimeType='video/x-ms-wmv' or
                            $mimeType='video/x-ms-asf'">
                <xsl:value-of select="concat($baseURL,'images/svg_icons/download_video.svg')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($derivateMaindoc) &gt; 0">
                      <xsl:variable name="ext"
                                    select="document(concat('callJava:org.apache.commons.io.FilenameUtils:getExtension:', $derivateMaindoc))"/>
                      <xsl:value-of
                        select="concat($baseURL,'images/svg_icons/download-generic.xml?XSL.Transformer=svg-download&amp;XSL.extension=', $ext)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($baseURL,'images/svg_icons/download_default.svg')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-doc-state-label">
        <xsl:param name="state-categ-id"/>
        <xsl:value-of select="document(concat('callJava:org.apache.commons.lang3.StringUtils:capitalize:', mcrxml:getDisplayName('state', $state-categ-id)))"/>
    </xsl:template>

</xsl:stylesheet>
