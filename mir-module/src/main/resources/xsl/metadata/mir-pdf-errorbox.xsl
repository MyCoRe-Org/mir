<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xalan="http://xml.apache.org/xalan"
                version="1.0" exclude-result-prefixes="i18n mcrxsl">

    <xsl:param name="ServletsBaseURL"/>


    <xsl:template match="mycoreobject" mode="displayPdfError">
        <xsl:variable name="errorMessages">
            <xsl:apply-templates select="structure/derobjects/derobject" mode="displayPdfError"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="contains($errorMessages,i18n:translate('pdf.errorbox.clause')) or
                contains($errorMessages,i18n:translate('pdf.errorbox.validationerror.message'))">
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
            <xsl:when test="string-length(normalize-space($errorMessages)) >0 and
            not(contains($errorMessages,i18n:translate('pdf.errorbox.validationerror.message')))">
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

    <xsl:template match="structure/derobjects/derobject" mode="displayPdfError">
        <xsl:variable name="derivateID" select="@xlink:href"/>
        <xsl:variable name="result" select="document(concat('pdfAValidator:', $derivateID))"/>
        <xsl:if test="not(normalize-space($result))">
            <xsl:apply-templates select="$result/derivate/file" mode="displayPdfError"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="file" mode="displayPdfError">
        <xsl:variable name="derivate" select="../@id"/>
        <xsl:variable name="name">
            <xsl:call-template name="pdfError.getFilename">
                <xsl:with-param name="filePath" select="@name"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="badgecolor">
            <xsl:choose>
                <xsl:when test="failed[@clause='Validation error!']">warning</xsl:when>
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
                    <xsl:choose>
                        <xsl:when test="$badgecolor = 'warning'">
                            !
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="count(failed)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </a>
        </div>
        <ul class="list-group collapse" id="collapse{$derivate}{$uniqueFileId}">
            <li class="list-group-item d-flex flex-column flex-xl-row flex-grow-2 text-break">
                <xsl:choose>
                    <xsl:when test="failed[@clause='Validation error!']">
                        <xsl:apply-templates select="failed" mode="displayValidationError"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <p class="flex-grow-1 col-xl-8 align-items-center">
                            <span class="text-muted pdf-term">
                                <xsl:value-of select="concat(i18n:translate('pdf.errorbox.conformity.level'),': ')"/>
                            </span>
                            <span class="pdf-value">
                                <xsl:value-of select="concat('PDF/A-',@flavour)"/>
                            </span>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:variable name="downloadLink">
                    <xsl:value-of
                            select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivate,'/',
                            mcrxsl:encodeURIPath(@name))"/>
                </xsl:variable>
                <div class="w-100 d-flex align-self-center justify-content-center">
                    <a role="button" href="{$downloadLink}" target="_blank"
                       class="btn btn-primary d-flex justify-content-center align-items-center w-100 py-2">
                        <xsl:value-of select="concat(i18n:translate('pdf.errorbox.button.download'),' ')"/>
                        <i class="fas fa-download ms-2"></i>
                    </a>
                </div>

            </li>
            <xsl:if test="not(@flavour='0')">
                <xsl:apply-templates select="failed" mode="displayPdfError"/>
            </xsl:if>
        </ul>
    </xsl:template>

    <xsl:template match="failed" mode="displayPdfError">
        <li class="list-group-item d-flex flex-column flex-xl-row flex-grow-1 text-break">
            <p class="flex-grow-1 col-xl-8 align-items-center">
                <span class="text-muted pdf-term">
                    <xsl:value-of select="concat(i18n:translate('pdf.errorbox.specification'),': ')"/>
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @specification, ' ')"/>
                </span>
                <span class="text-muted pdf-term">
                    <xsl:value-of select="concat(i18n:translate('pdf.errorbox.clause'),': ')"/>
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @clause, ' ')"/>
                </span>
                <span class="text-muted pdf-term">
                    <xsl:value-of select="concat(i18n:translate('pdf.errorbox.test'),': ')"/>
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @testNumber, ' ')"/>
                </span>
            </p>
            <xsl:choose>
                <xsl:when test="not(@link)">
                    <div class="w-100 d-flex align-self-center justify-content-center">
                        <a role="button" href="{@Link}" target="_blank"
                           class="btn btn-info col d-flex justify-content-center align-items-center w-100 py-2">
                            <xsl:value-of select="concat(i18n:translate('pdf.errorbox.button.info'),' ')"/>
                            <i class="fas fa-external-link-alt ms-2"></i>
                        </a>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="text-center alert alert-danger col" role="alert">
                        <xsl:value-of select="i18n:translate('pdf.errorbox.unknown.error')"/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="failed" mode="displayValidationError">
        <span class="flex-grow-1 col-xl-8 align-items-center">
            <p class="text-danger mb-2">
                <xsl:value-of select="i18n:translate('pdf.errorbox.validationerror.message')"/>
            </p>
        </span>
    </xsl:template>


    <xsl:template name="pdfError.getFilename">
        <xsl:param name="filePath"/>
        <xsl:variable name="rest-of" select="substring-after($filePath, '/')"/>
        <xsl:choose>
            <xsl:when test="contains($rest-of, '/')">
                <xsl:call-template name="pdfError.getFilename">
                    <xsl:with-param name="filePath" select="$rest-of"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="normalize-space($rest-of)">
                    <xsl:value-of select="$rest-of"/>
                </xsl:if>
                <xsl:if test="not(normalize-space($rest-of))">
                    <xsl:value-of select="$filePath"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
