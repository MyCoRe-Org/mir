<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xalan="http://xml.apache.org/xalan"
                version="1.0" exclude-result-prefixes="i18n mcrxsl">

    <xsl:variable name="foo" select="structure/derobjects/derobject/xlink:href/collection/dir/file"/>
    <xsl:param name="WebApplicationBaseURL"/>
    <xsl:param name="ServletsBaseURL" />
    <xsl:param name="HttpSession"/>
    <xsl:template match="mycoreobject" mode="displayPdfError">


        <xsl:variable name="errorMessages">
            <xsl:apply-templates
                    select="structure/derobjects/derobject"/>
        </xsl:variable>




        <xsl:choose>
            <xsl:when test="contains($errorMessages,'Clause')">
                <div class="container pdf-validation mb-3 px-0" id="accordion">
                    <div class="card-header bg-danger text-white">
                        <div class="list-group list-group-root well p-3">
                            <p class="h5">
                                <xsl:value-of select="i18n:translate('pdf.errorbox.warning.heading')"/>
                            </p>
                            <p>
                                <xsl:value-of select="i18n:translate('pdf.errorbox.warning.message')"/>
                            </p>
                        </div>
                    </div>
                    <div class="card-body border-left border-right border-bottom">
                        <xsl:copy-of select="$errorMessages"/>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($errorMessages)) > 0 and not(contains($errorMessages,'Clause'))">
                <div class="card-header bg-success text-white mb-3">
                    <div class="list-group list-group-root well p-3">
                        <p class="h5">
                            <xsl:value-of select="i18n:translate('pdf.errorbox.success.heading')"/>
                        </p>
                        <p>
                            <xsl:value-of select="i18n:translate('pdf.errorbox.success.message')"/>
                        </p>
                    </div>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="structure/derobjects/derobject">
        <xsl:variable name="derivateID" select="@xlink:href"/>
        <xsl:variable name="result" select="document(concat('pdfAValidator:', $derivateID))"/>
        <xsl:if test="not(normalize-space($result))">
            <xsl:apply-templates select="$result/derivate/file"/>
        </xsl:if>
        <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$result/derivate/@id,'/')" />
        <xsl:variable name="derivdir" select="concat($derivbase,$HttpSession)" />
    </xsl:template>


    <xsl:template match="file">
        <xsl:variable name="derivate" select="../@id"/>


        <xsl:variable name="name">
            <xsl:call-template name="getFilename">
                <xsl:with-param name="filePath" select="@name"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="badgecolor">
            <xsl:choose>
                <xsl:when test="failed">danger</xsl:when>
                <xsl:otherwise>success</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="uniqueFileId" select="generate-id(.)"/>
        <div id="{$derivate}{$uniqueFileId}" class="font-weight-bold d-flex list-group list-group-root">
            <a onclick="$('#{$derivate}{$uniqueFileId}cbButton').toggleClass('fa-chevron-right fa-chevron-down');"
               data-toggle="collapse" href="#collapse{$derivate}{$uniqueFileId}"
               class="text-left  d-flex  flex-md-row flex-grow-1 list-group-item align-items-center">
                <i id="{$derivate}{$uniqueFileId}cbButton" class="fa fa-chevron-right ml-auto mr-1"/>
                <span class="flex-grow-1 font-weight-bold text-break">
                    <xsl:value-of select="$name"/>
                </span>
                <span class="badge badge-{$badgecolor} badge-pill align-self-center">
                    <xsl:value-of select="count(failed)"/>
                </span>
            </a>
        </div>
        <ul class="list-group collapse" id="collapse{$derivate}{$uniqueFileId}">
            <li class="list-group-item d-flex flex-column flex-xl-row flex-grow-2 text-break">
                <p class="flex-grow-1 col-lg-8 align-items-center">
                    <span class="text-muted pdf-term">
                        <xsl:value-of select="concat(i18n:translate('pdf.errorbox.conformity.level'),': ')"/>
                    </span>
                    <span class="pdf-value">
                        <xsl:value-of select="concat('PDF/A-',@flavour)"/>
                    </span>
                </p>
                <xsl:variable name="downloadLink">
                    <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivate,'/',mcrxsl:encodeURIPath(@name))"/>
                </xsl:variable>


                <a class="btn  btn-primary col" href="{$downloadLink}" target="_blank">
                    <xsl:value-of select="concat(i18n:translate('pdf.errorbox.button.download'),' ')"/>
                    <i class="fas fa-download"/>
                </a>
            </li>
            <xsl:apply-templates select="failed"/>
        </ul>
    </xsl:template>


    <xsl:template match="failed">
        <li class="list-group-item d-flex flex-column flex-xl-row flex-grow-1 text-break">
            <p class="flex-grow col-lg-8 col-md-9 align-self-center">
                <span class="text-muted pdf-term">
                    Specification:
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @specification, ' ')"/>
                </span>
                <span class="text-muted pdf-term">
                    Clause:
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @clause, ' ')"/>
                </span>
                <span class="text-muted pdf-term">
                    Test:
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @testNumber, ' ')"/>
                </span>
            </p>
            <xsl:choose>
                <xsl:when test="not(@link)">
                    <a class="btn btn-info col" role="button" href="{@Link}" target="_blank">
                        <xsl:value-of select="concat(i18n:translate('pdf.errorbox.button.info'),' ')"/>
                        <i class="fas fa-external-link-alt"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <div class="text-center alert alert-danger col" role="alert">
                        <xsl:value-of select="i18n:translate('pdf.errorbox.unknown.error')"/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>


    <xsl:template name="getFilename">
        <xsl:param name="filePath" />
        <xsl:variable name="rest-of" select="substring-after($filePath, '/')" />
        <xsl:choose>
            <xsl:when test="contains($rest-of, '/')">
                <xsl:call-template name="getFilename">
                    <xsl:with-param name="filePath" select="$rest-of" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="normalize-space($rest-of)">
                    <xsl:value-of select="$rest-of" />
                </xsl:if>
                <xsl:if test="not(normalize-space($rest-of))">
                    <xsl:value-of select="$filePath" />
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
